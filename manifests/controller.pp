# To see if everything works fine, run validate-cloud.sh

Exec { logoutput => 'on_failure' }


## Database ##

class { 'mysql::server':
  override_options => { 'mysqld' => { 'bind-address' => "${::ipaddress_eth1}" } },
  restart   => true,
}

class { 'keystone::db::mysql':
  password => 'keystone',
  mysql_module   => '2.2',
  allowed_hosts => '%',
}

class { 'glance::db::mysql':
  password      => 'glance',
  mysql_module   => '2.2',
  allowed_hosts => '%',
}

class { 'nova::db::mysql':
  password      => 'nova',
  mysql_module  => '2.2',
  allowed_hosts => '%',
}

class { 'neutron::db::mysql':
  password      => 'neutron',
  mysql_module  => '2.2',
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
  database_connection => "mysql://cloud:cloud@${::ipaddress_eth1}/keystone",
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
  sql_connection    => "mysql://cloud:cloud@${::ipaddress_eth1}/glance",
  mysql_module   => '2.2',
}

class { 'glance::registry':
  verbose           => true,
  auth_host         => "${::fqdn}",
  auth_port         => '5000',
  auth_protocol     => 'https',
  keystone_tenant   => 'services',
  keystone_user     => 'glance',
  keystone_password => 'glance',
  sql_connection    => "mysql://cloud:cloud@${::ipaddress_eth1}/glance",
  mysql_module   => '2.2',
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
  database_connection => "mysql://cloud:cloud@${::ipaddress_eth1}/nova?charset=utf8",
  rabbit_userid       => 'rabbituser',
  rabbit_password     => 'rabbitpass',
  image_service       => 'nova.image.glance.GlanceImageService',
  glance_api_servers  => "${::fqdn}:9292",
  verbose             => true,
  rabbit_hosts                  => [
    "${::fqdn}:5672"
  ],
  mysql_module   => '2.2',
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

class { 'nova::network::neutron':
  neutron_admin_password    => 'neutron',
  neutron_url               => "http://${::ipaddress_eth1}:9696",
  neutron_admin_auth_url    => "https://${::fqdn}:5000/v2.0",
}

class { 'neutron':
  allow_overlapping_ips     => true, # Enables network namespaces
  verbose           => true,
  debug             => true,
  #TODO(rushiagr): see service_plugins option. More specifically, see if
  #'router' service plugin is required.
  #service_plugin    => 'router',
  rabbit_user       => 'rabbituser',
  rabbit_password   => 'rabbitpass',
  rabbit_host       => "${::ipaddress_eth1}",
  log_file          => 'test_neutron_logfilename',
}

class { 'neutron::server':
  auth_password     => 'neutron',
  auth_host         => "${::fqdn}",
  auth_port         => '5000',
  auth_protocol     => 'https',
  database_connection => "mysql://cloud:cloud@${::ipaddress_eth1}/neutron",
  #TODO(rushiagr): check if this sync db thing is required, or can be removed
  sync_db           => True,
  mysql_module      => '2.2',
}

class { 'neutron::plugins::ovs':
  #NOTE(rushiagr): this needs to be changed to vlan if we want vlan and not
  #gre, or vice versa
  tenant_network_type => 'vlan',
  network_vlan_ranges => 'physnet:100:200',
}

#NOTE(rushiagr): not sure if this is required for minimal neutron to work
#successfully, but adding anyways, because it is listed in
#puppet-neutron/examples/neutron.pp
class { 'neutron::server::notifications':
  nova_admin_tenant_name => 'services',
#  nova_admin_username => 'nova',
  nova_url      => "http://${::fqdn}:8774/v2",
  nova_admin_auth_url => "https://${::fqdn}:5000/v2.0",
  nova_admin_password => 'nova',
}

#TODO(rushiagr): see if neutron::agents::ovs is actually required on the
#controller node, even if we're not using controller node as a compute machine
#
#TODO(rushiagr): not sure if tunneling and local IP is required for vlan too
#(i.e. not vxlan)
class { 'neutron::agents::ovs':
  local_ip => "${::ipaddress_eth1}",
  enable_tunneling => true,
}

class { 'neutron::agents::dhcp':
  debug => true,
}

class { 'neutron::agents::l3':
  debug => true,
  use_namespaces => true,
  #NOTE(rushiagr): default value of the below option is  true. we might need to
  #understand how to configure it and understand it a bit more in the future
  #handle_internal_only_routers => false,
}

# ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
#class { 'neutron::plugins::ml2':
#  type_drivers          => ['vxlan'],
#  tenant_network_types  => ['vxlan'],
#  vxlan_group           => '239.1.1.1',
#  mechanism_drivers     => ['openvswitch'],
#  vni_ranges            => ['0:300']
#}

include neutron::client

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



# Compute
class { 'nova::compute':
  enabled       => true,
  vnc_enabled   => true,
  neutron_enabled   => true,
}

class { 'nova::compute::libvirt':
  libvirt_virt_type     => 'qemu',
}
