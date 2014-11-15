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
# NOTE(rushiagr): setting "enabled => false" will result in an error. This is
# because, even if the service is disabled, the class keystone::roles::admin
# is defined, which will then try to access keystone. We should fix this up in
# future.

# NOTE(rushiagr): Do not set this to true if apache is enabled, as in this
# site.pp. If set to true, then keystone will try to run on both apache as well
# as WSGI servers, and this will lead to "Port/address in use" errors.
  enabled        => false,
  enable_ssl     => true,

# TODO(rushiagr): These files for now need to be added manually. In future, we
# should make creation of these files automatic
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

include apache
class { 'keystone::wsgi::apache':
  ssl => true
}
