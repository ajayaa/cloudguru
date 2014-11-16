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
  token_provider => 'keystone.token.providers.uuid.Provider',

# NOTE(rushiagr): Do not set this to true if apache is enabled, as in this
# site.pp. If set to true, then keystone will try to run on both apache as well
# as WSGI servers, and this will lead to "Port/address in use" errors.
  enabled        => false,
  enable_ssl     => true,
  admin_endpoint => "https://${::fqdn}:35357/v2.0/",
  public_endpoint => "https://${::fqdn}:5000/v2.0/",
}

class { 'keystone::roles::admin':
  admin_tenant  => 'admin',
  email         => 'rushi.agr@gmail.com',
  password      => 'ChangeMe',
}

# Example of how to add a role
#keystone_role { ['nonadmin']:
#     ensure => present,
#}

class { 'keystone::endpoint':
  public_url => "https://${::fqdn}:5000",
  admin_url  => "https://${::fqdn}:35357",
  internal_url => "https://${::fqdn}:35357",
}

include apache
class { 'keystone::wsgi::apache':
  ssl => true,
  ssl_cert => '/home/vagrant/cloudguru/ssl/fake.crt',
  ssl_key => '/home/vagrant/cloudguru/ssl/fake.key',
}

class { 'glance::api':
  verbose           => true,
  auth_host         => '192.168.100.1',
  auth_url          => 'http://192.168.100.1:5000/v2.0',
  auth_port         => '5000',
  keystone_tenant   => 'service',
  keystone_user     => 'glance',
  keystone_password => '123',
  sql_connection    => 'mysql://root:123@192.168.100.1/glance',
}

class { 'glance::registry':
  verbose           => true,
  auth_host         => '192.168.100.1',
  auth_port         => '5000',
  keystone_tenant   => 'service',
  keystone_user     => 'glance',
  keystone_password => '123',
  sql_connection    => 'mysql://root:123@192.168.100.1/glance',
}

class { 'glance::backend::file': }

class { 'glance::notify::rabbitmq':
  rabbit_password               => '123',
  rabbit_userid                 => 'guest',
  rabbit_hosts                  => [
    '192.168.100.1:5672'
  ],
  rabbit_use_ssl                => false,
}
