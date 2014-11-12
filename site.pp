# Example using apache to serve keystone
#
# To be sure everything is working, run:
#   $ export OS_USERNAME=admin
#   $ export OS_PASSWORD=ChangeMe
#   $ export OS_TENANT_NAME=openstack
#   $ export OS_AUTH_URL=http://keystone.local/keystone/main/v2.0
#   $ keystone catalog
#   Service: identity
#   +-------------+----------------------------------------------+
#   |   Property  |                    Value                     |
#   +-------------+----------------------------------------------+
#   |   adminURL  | http://keystone.local:80/keystone/admin/v2.0 |
#   |      id     |       4f0f55f6789d4c73a53c51f991559b72       |
#   | internalURL | http://keystone.local:80/keystone/main/v2.0  |
#   |  publicURL  | http://keystone.local:80/keystone/main/v2.0  |
#   |    region   |                  RegionOne                   |
#   +-------------+----------------------------------------------+
#

Exec { logoutput => 'on_failure' }

class { 'mysql::server': }
class { 'keystone::db::mysql':
  password => 'keystone',
  mysql_module   => '2.2',
  allowed_hosts => '%',
}
class { 'keystone':
  verbose        => true,
  debug          => true,
  database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
  catalog_type   => 'sql',
  admin_token    => 'admin_token',
  mysql_module   => '2.2',
# NOTE(rushiagr): setting enabled => false will result in an error due to
# dependent declarations still getting evaluated even when keystone service is
# not running. Might fix this up in future
  enabled        => true,
#  enabled        => false,
  enable_ssl     => true,
  ssl_certfile   => "/home/vagrant/keystone-ssl/ssl-cert-snakeoil.pem",
  ssl_keyfile    => "/home/vagrant/keystone-ssl/ssl-cert-snakeoil.key",
}
class { 'keystone::roles::admin':
  email    => 'test@puppetlabs.com',
  password => 'ChangeMe',
}
class { 'keystone::endpoint':
  public_url => "https://${::fqdn}:5000",
  admin_url  => "https://${::fqdn}:35357",
}

#keystone_config { 'ssl/enable': value => false }

#include apache
#class { 'keystone::wsgi::apache':
#  ssl => true
#}

