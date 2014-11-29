#! /bin/bash
set -eux

sudo ifdown eth0
sudo route add default gw 192.168.100.1 #TODO: make the IP an argument
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
