#! /bin/bash
set -eux

source ~/cloudguru/scripts/adminrc

glance image-create --name cirros --disk-format qcow2 --container-format bare \
    --is-public True --progress < ~/cloudguru/files/cirros-0.3.2-x86_64-disk.img

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

nova flavor-create m1.nano 6 64 0 1

neutron net-create mynet
neutron subnet-create --name mynet-subnet mynet 10.0.0.0/24
neutron router-create myrouter
neutron router-interface-add myrouter mynet-subnet
