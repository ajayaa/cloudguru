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
class { 'glance::db::mysql':
  password      => 'glance',
  allowed_hosts => '%',
  mysql_module   => '2.2',
}

class { 'keystone':
  verbose        => true,
  debug          => true,
  database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
  catalog_type   => 'sql',
  admin_token    => 'admin_token',
  mysql_module   => '2.2',

# Default is PKI token for Icehouse. Here we're changing it to UUID
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
  auth_host         => 'node1.example.com',
  auth_url          => 'https://node1.example.com:5000/v2.0',
  auth_port         => '5000',
  auth_protocol     => 'https',
  keystone_tenant   => 'services',
  keystone_user     => 'glance',
  keystone_password => 'glance',
  sql_connection    => 'mysql://glance:glance@127.0.0.1/glance',
  mysql_module   => '2.2',
}

class { 'glance::registry':
  verbose           => true,
  auth_host         => 'node1.example.com',
  auth_port         => '5000',
  auth_protocol     => 'https',
  keystone_tenant   => 'services',
  keystone_user     => 'glance',
  keystone_password => 'glance',
  sql_connection    => 'mysql://glance:glance@127.0.0.1/glance',
  mysql_module   => '2.2',
}

class { 'glance::backend::file': }

class { 'rabbitmq':
  default_user  => 'mydefaultuser',
  default_pass  => 'mydefaultpass',
}

rabbitmq_user { 'rabbituser':
  admin     => true,
  password  => 'rabbitpass',
}


rabbitmq_user_permissions { 'rabbituser@/':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
class { 'glance::notify::rabbitmq':
  rabbit_userid                 => 'rabbituser',
  rabbit_password               => 'rabbitpass',
  rabbit_hosts                  => [
    "node1.example.com:5672"
  ],
  rabbit_use_ssl                => false,
}

class { 'glance::keystone::auth':
  password         => 'glance',
  email            => 'glance@example.com',
  public_address   => 'node1.example.com',
  admin_address    => 'node1.example.com',
  internal_address => 'node1.example.com',
  region           => 'RegionOne',
}
