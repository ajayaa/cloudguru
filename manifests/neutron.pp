# blah

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

#NOTE(rushiagr): not sure if this is required for minimal neutron to work
#successfully, but adding anyways, because it is listed in
#puppet-neutron/examples/neutron.pp
class { 'neutron::server::notifications':
  nova_admin_tenant_name => 'services',
  nova_admin_username => 'nova',
  nova_url      => "http://${::fqdn}:8774/v2",
  nova_admin_auth_url => "https://${::fqdn}:5000/v2.0",
  nova_admin_password => 'nova',
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
  database_connection => "mysql://neutron:neutron@${::ipaddress_eth1}/neutron",
  #TODO(rushiagr): check if this sync db thing is required, or can be removed
  sync_db           => True,
}

