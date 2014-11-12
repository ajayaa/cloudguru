Yet another OpenStack cloud deployment repository

## Installation

Make sure the machine has an FQDN set

    sudo apt-get install -y git
    git clone https://github.com/ajayaa/cloudguru.git
    sudo gem install librarian-puppet-simple --no-ri --no-rdoc

Add a Puppetfile, and run

    librarian-puppet install

to get installed all the Puppet modules defined in Puppetfile. To update the
modules later, run:

    librarian-puppet update
## Puppet apply

    sudo puppet apply site.pp --modulepath modules/

## Verification
Verify if the keystone got successfully installed:

    keystone --os-auth-url http://node2.example.com:5000/v2.0 --os-username admin --os-password ChangeMe --os-tenant-name openstack catalog
