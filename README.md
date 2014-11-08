Yet another OpenStack cloud deployment repository

## Installation

    sudo apt-get install -y git
    git clone https://github.com/ajayaa/cloudguru.git
    sudo gem install librarian-puppet-simple

Add a Puppetfile, and run

    librarian-puppet install

to get installed all the Puppet modules defined in Puppetfile. To update the
modules later, run:

    librarian-puppet update
