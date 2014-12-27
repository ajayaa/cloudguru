class { 'mysql::server':}


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
  #core_plugin       => 'ml2',
  core_plugin       => 'neutron.plugins.ml2.plugin.Ml2Plugin',
}

class { 'neutron::server':
  auth_password     => 'neutron',
  auth_host         => "${::fqdn}",
  auth_port         => '5000',
  auth_protocol     => 'https',
  database_connection => "mysql://neutron:neutron@${::ipaddress_eth1}/neutron",
  sync_db           => True,
}

class { 'neutron::agents::ml2::ovs':
  local_ip         => "${::ipaddress_eth1}",
  enable_tunneling => true,
  tunnel_types     => 'vxlan',
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

# ml2 plugin with vxlan as ml2 driver and ovs and linux_bridge as mechanism driver
class { 'neutron::plugins::ml2':
  type_drivers          => ['vxlan'],
  tenant_network_types  => ['vxlan'],
  vni_ranges            => ['1001:2000']
}

include neutron::client
