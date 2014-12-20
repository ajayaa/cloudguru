#! /bin/bash
set -eux

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ChangeMe
export OS_AUTH_URL=https://node1.example.com:5000/v2.0

unset http_proxy

keystone token-get
keystone user-list
keystone tenant-list

glance image-list

nova flavor-list
nova list
nova image-list
nova host-list
nova network-list

neutron net-list
neutron router-list
neutron subnet-list
