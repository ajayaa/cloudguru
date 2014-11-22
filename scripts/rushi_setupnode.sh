HOST_MC_IP=192.168.100.1
HOST_MC_USER=r
HOST_MODULES_SOURCE=/home/r/src/cloudguru/modules


# assumes librarian-puppet is already installed
# assumes cloudguru directory is placed directly under home dir
cd ~/cloudguru

mkdir modules
rsync -r $HOST_MC_USER@$HOST_MC_IP:$HOST_MODULES_SOURCE modules

scp -r r@$HOST_MC_IP:/home/r/src/cloudguru/cirros032.img .

sudo puppet apply site.pp --debug --modulepath modules/

sudo cp ssl/fake.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

source adminrc

glance image-create --name cirros032 --disk-format qcow2 --container-format bare --is-public True --progress < cirros-0.3.2-x86_64-disk.img

## Nova
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

nova keypair-add rushi >> rushi.pem

nova boot --image cirros032 --flavor m1.tiny inst_one
