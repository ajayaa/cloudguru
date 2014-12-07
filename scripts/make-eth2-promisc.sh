#! /bin/bash
set -eux

sudo rm /etc/network/interfaces
sudo cp /home/vagrant/cloudguru/scripts/interfaces /etc/network/interfaces
sudo ifdown eth2 && sudo ifup eth2
