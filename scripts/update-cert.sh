#! /bin/bash
set -eux

# Updates certificates into the system

sudo cp /home/vagrant/cloudguru/ssl/fake.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

