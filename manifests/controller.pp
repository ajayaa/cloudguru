# To see if everything works fine, run validate-cloud.sh

Exec { logoutput => 'on_failure' }


## Database ##

class { 'mysql::server':
  override_options => { 'mysqld' => { 'bind-address' => "${::ipaddress_eth1}" } },
  restart   => true,
}

class { 'keystone::db::mysql':
  password => 'keystone',
  allowed_hosts => '%',
#  mysql_module => '2.2',
}

class { 'glance::db::mysql':
  password      => 'glance',
  allowed_hosts => '%',
}

class { 'nova::db::mysql':
  password      => 'nova',
  allowed_hosts => '%',
}

class { 'neutron::db::mysql':
  password      => 'neutron',
  allowed_hosts => '%',
}

## Service registration with Keystone ##

class { 'glance::keystone::auth':
  password         => 'glance',
  email            => 'glance@example.com',
  public_address   => "${::fqdn}",
  admin_address    => "${::fqdn}",
  internal_address => "${::fqdn}",
  region           => 'RegionOne',
}

class { 'nova::keystone::auth':
  password      => 'nova',
}


class { 'keystone':
  verbose        => true,
  debug          => true,
  database_connection => "mysql://keystone:keystone@${::ipaddress_eth1}/keystone",
  catalog_type   => 'sql',
  admin_token    => 'admin_token',
  rabbit_userid  => 'rabbituser',
  rabbit_password => 'rabbitpass',

# Default is PKI token for Icehouse. Here we're changing it to UUID
  token_provider => 'keystone.token.providers.uuid.Provider',

# NOTE(rushiagr): Do not set this to true if apache is enabled, as in this
# site.pp. If set to true, then keystone will try to run on both apache as well
# as WSGI servers, and this will lead to "Port/address in use" errors.
  enabled        => false,
  enable_ssl     => true,
  admin_endpoint => "https://${::fqdn}:35357/",
  public_endpoint => "https://${::fqdn}:5000/",
}

class { 'keystone::roles::admin':
  admin_tenant  => 'admin',
  email         => 'rushi.agr@gmail.com',
  password      => 'ChangeMe',
}

# Example of how to add a role
#keystone_role { ['nonadmin']:
#  ensure => present,
#}

class { 'keystone::endpoint':
  public_url => "https://${::fqdn}:5000",
  admin_url  => "https://${::fqdn}:35357",
  internal_url => "https://${::fqdn}:35357",
}

include apache
class { 'keystone::wsgi::apache':
  ssl => true,
  ssl_cert => '/home/vagrant/cloudguru/files/ssl/fake.crt',
  ssl_key => '/home/vagrant/cloudguru/files/ssl/fake.key',
}

class { 'glance::api':
  verbose           => true,
  auth_host         => "${::fqdn}",
  auth_port         => '5000',
  auth_protocol     => 'https',
  keystone_tenant   => 'services',
  keystone_user     => 'glance',
  keystone_password => 'glance',
  sql_connection    => "mysql://glance:glance@${::ipaddress_eth1}/glance",
}

class { 'glance::registry':
  verbose           => true,
  auth_host         => "${::fqdn}",
  auth_port         => '5000',
  auth_protocol     => 'https',
  keystone_tenant   => 'services',
  keystone_user     => 'glance',
  keystone_password => 'glance',
  sql_connection    => "mysql://glance:glance@${::ipaddress_eth1}/glance",
}

class { 'glance::backend::file': }

#NOTE Adding user and set permission only should be done once.
#rabbitmq_user { 'rabbituser':
#  admin     => true,
#  password  => 'rabbitpass',
#}
#
class { 'rabbitmq':
  delete_guest_user => true,
} ->

exec { "create_rabbituser":
  command => "rabbitmqctl add_user rabbituser rabbitpass",
  path    => '/usr/sbin:/usr/bin:/bin',
} ->

rabbitmq_user_permissions { 'rabbituser@/':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}

class { 'glance::notify::rabbitmq':
  rabbit_userid                 => 'rabbituser',
  rabbit_password               => 'rabbitpass',
  rabbit_hosts                  => [
    "${::fqdn}:5672"
  ],
  rabbit_use_ssl                => false,
}

class { 'nova':
  database_connection => "mysql://nova:nova@${::ipaddress_eth1}/nova?charset=utf8",
  rabbit_userid       => 'rabbituser',
  rabbit_password     => 'rabbitpass',
  image_service       => 'nova.image.glance.GlanceImageService',
  glance_api_servers  => "${::fqdn}:9292",
  verbose             => true,
  rabbit_hosts                  => [
    "${::fqdn}:5672"
  ],
}

class { 'nova::api':
  admin_password    => 'nova',
  enabled           => true,
  auth_host         => "${::fqdn}",
  auth_protocol     => 'https', 
  admin_tenant_name => 'services',
}

#class { 'nova::compute':
#  enabled                       => true,
#  vnc_enabled                   => true,
#}
#
#class { 'nova::compute::libvirt':
#  libvirt_virt_type     => 'qemu',
#  #migration_support => true,
#}

class { 'nova::conductor':
  enabled       => true,
}

class { 'nova::scheduler':
  enabled       => true,
}

include nova::client

#TODO: remove this
#class { 'nova::network':
##  fixed_range           => '11.1.1.1/24',
#  private_interface     => 'eth2',
#  enabled               => 'true',
#}

#class { 'nova::network::flatdhcp':
#  fixed_range           => '11.1.1.1/24',
#}


# Compute
class { 'nova::compute':
  enabled       => true,
  vnc_enabled   => true,
  neutron_enabled   => true,
}

class { 'nova::compute::libvirt':
  libvirt_virt_type     => 'qemu',
}

class { 'neutron::keystone::auth':
  password          => 'neutron',
  auth_name         => 'neutron',
  email             => 'neutron@example.com',
  tenant            => 'services',
  public_address    => "${::fqdn}",
  admin_address     => "${::fqdn}",
  internal_address  => "${::fqdn}",
  region            => 'RegionOne',
}

class { 'nova::network::neutron':
  neutron_admin_password    => 'neutron',
  neutron_url               => "http://${::ipaddress_eth1}:9696",
  neutron_admin_auth_url    => "https://${::fqdn}:5000/v2.0",
  vif_plugging_is_fatal     => false,
  vif_plugging_timeout      => 10,
}
