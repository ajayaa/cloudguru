#! /bin/bash
set -eux

# brings eth0 interface down, but makes internet work with eth1 IP
# Assumes forwarding rules were added to the host machine so that the eth1's
# gateway has internet access.

sudo ifdown eth0
sudo route add default gw $(facter ipaddress_eth1 | cut -d '.' -f1,2,3).1
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
