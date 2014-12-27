Yet another OpenStack cloud deployment repository

## Installation

Make sure the machine has an FQDN set.

Install git

    sudo apt-get install -y git

Clone `cloudguru` repository

    git clone https://github.com/ajayaa/cloudguru.git

Install gem `librarian-puppet-simple`

    sudo gem install librarian-puppet-simple --no-ri --no-rdoc

Go to the directory where Puppetfile resides, and run `librarian-puppet
install`:

    cd cloudguru/
    librarian-puppet install

To get installed all the Puppet modules defined in Puppetfile. To update the
modules later, run:

    librarian-puppet update

## Puppet apply

    sudo puppet apply site.pp --modulepath modules/

## Verification
Verify if the keystone got successfully installed:

    keystone --os-auth-url http://node2.example.com:5000/v2.0 --os-username admin --os-password ChangeMe --os-tenant-name openstack catalog

## Glance

Download image like this:

    wget http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img

Now upload it to glance directly

    glance image-create --name cirros032 --disk-format qcow2 --container-format bare --is-public True --progress < cirros-0.3.2-x86_64-disk.img

## Nova

Add securitygroup rules

    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

Add a keypair (actually not necessary for cirros image)

    nova keypair-add rushi >> rushi.pem

Boot nova instance

    nova boot --image cirros032 --flavor m1.tiny inst_one

Now ping VM:

    ping 10.0.0.2


### For juno
    sudo add-apt-repository cloud-archive:juno

### Neutron

To reload ML2 configuration:

    service neutron-plugin-openvswitch-agent start

To add br-ex bridge:

    sudo ovs-vsctl add-br br-ex

To attach eth2 to br-ex:

    sudo ovs-vsctl add-port br-ex eth2
