#!/bin/bash
set -eux

for i in "neutron" "nova" "keystone" "glance"; do
    mysql -u$i -p$i -e "drop database $i"
done
