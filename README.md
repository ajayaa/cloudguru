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
