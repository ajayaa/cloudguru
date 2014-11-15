# Example using apache to serve keystone, with SSL
#
# To be sure everything is working, run:
# $ keystone  \
#     --os-auth-url=https://<IP>:5000/v2.0 \
#     --os-username admin \
#     --os-password ChangeMe \
#     --os-tenant-name openstack \
#     --insecure \
#     catalog

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
# NOTE(rushiagr): setting "enabled => false", and also not running the Apache
# server will result in an error. This is
# because, even if the service is disabled, the class keystone::roles::admin
# is defined, which will then try to access keystone. We should fix this up in
# future.

# NOTE(rushiagr): Do not set this to true if apache is enabled, as in this
# site.pp. If set to true, then keystone will try to run on both apache as well
# as WSGI servers, and this will lead to "Port/address in use" errors.
  enabled        => false,
  enable_ssl     => true,
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
