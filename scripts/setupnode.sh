#! /bin/bash

set -eux

# assumes librarian-puppet is already installed
# assumes cloudguru directory is placed directly under home dir
cd ~/cloudguru
librarian-puppet install

# setup FQDN
HOSTNAME=$(hostname)
echo "127.0.1.1 $HOSTNAME.example.com $HOSTNAME" | sudo tee --append /etc/hosts

sudo puppet apply site.pp --debug --modulepath modules/

sudo cp ssl/fake.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

source adminrc


wget http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img

glance image-create --name cirros032 --disk-format qcow2 --container-format bare --is-public True --progress < cirros-0.3.2-x86_64-disk.img

nova boot --image cirros032 --flavor m1.tiny inst_one
