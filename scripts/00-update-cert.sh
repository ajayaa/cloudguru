#! /bin/bash
set -eux

# Updates certificates into the system

sudo cp /home/vagrant/cloudguru/files/ssl/fake.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

