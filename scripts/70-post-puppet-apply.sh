#! /bin/bash
set -eux

source ~/cloudguru/scripts/adminrc

glance image-create --name cirros --disk-format qcow2 --container-format bare \
    --is-public True --progress < ~/cloudguru/files/cirros-0.3.2-x86_64-disk.img

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

nova flavor-create m1.nano 6 64 0 1

sudo ovs-vsctl add-br br-ex
sudo ovs-vsctl add-port br-ex eth2

neutron net-create private
neutron subnet-create --name private-subnet private 10.0.0.0/24

neutron net-create public --router:external True
neutron subnet-create --name public-subnet public 192.168.200.0/24

neutron router-create myrouter
neutron router-interface-add myrouter private-subnet
neutron router-gateway-set myrouter public
