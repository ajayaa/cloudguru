#! /bin/bash
set -eux


HOST_MC_IP=192.168.100.1
HOST_MC_USER=r
HOST_MODULES_SOURCE=/home/r/src/cloudguru/modules


sudo puppet apply site.pp --debug --modulepath modules/

source adminrc

glance image-create --name cirros032 --disk-format qcow2 --container-format bare --is-public True --progress < cirros-0.3.2-x86_64-disk.img

nova boot --image cirros032 --flavor m1.tiny inst_one
