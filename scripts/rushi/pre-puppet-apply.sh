#! /bin/bash
set -eux

# Gets modules directory from local host machine
# Gets cirros image too from local machine
# Sets FQDN
# Adds SSL certificate

HOST_MC_IP=192.168.100.1
HOST_MC_USER=r
HOST_MODULES_SOURCE=/home/r/src/cloudguru/modules
CLOUDGURU_DIR=/home/vagrant/cloudguru

HOSTNAME=$(hostname)
echo "127.0.1.1 $HOSTNAME.example.com $HOSTNAME" | sudo tee --append /etc/hosts

rsync -r $HOST_MC_USER@$HOST_MC_IP:$HOST_MODULES_SOURCE $CLOUDGURU_DIR

scp -r r@$HOST_MC_IP:/home/r/src/cloudguru/cirros-0.3.2-x86_64-disk.img $CLOUDGURU_DIR

sudo cp $CLOUDGURU_DIR/ssl/fake.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
