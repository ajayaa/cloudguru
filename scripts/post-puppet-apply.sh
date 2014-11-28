#! /bin/bash
set -eux

source ~/cloudguru/adminrc

glance image-create --name cirros --disk-format qcow2 --container-format bare --is-public True --progress < ~/cloudguru/cirros-0.3.2-x86_64-disk.img

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
