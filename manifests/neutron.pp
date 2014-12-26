# blah


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
  #TODO(rushiagr): check if this sync db thing is required, or can be removed
  sync_db           => True,
}





#class { 'neutron::plugins::ovs':
#  #NOTE(rushiagr): this needs to be changed to vlan if we want vlan and not
#  #gre, or vice versa
#  tenant_network_type => 'vxlan',
#  #network_vlan_ranges => 'physnet:100:200',
#}

#NOTE(rushiagr): not sure if this is required for minimal neutron to work
#successfully, but adding anyways, because it is listed in
#puppet-neutron/examples/neutron.pp
#class { 'neutron::server::notifications':
#  nova_admin_tenant_name => 'services',
#  nova_admin_username => 'nova',
#  nova_url      => "http://${::fqdn}:8774/v2",
#  nova_admin_auth_url => "https://${::fqdn}:5000/v2.0",
#  nova_admin_password => 'nova',
#}

#TODO(rushiagr): see if neutron::agents::ovs is actually required on the
#controller node, even if we're not using controller node as a compute machine
#
#TODO(rushiagr): not sure if tunneling and local IP is required for vlan too
#(i.e. not vxlan)
#class { 'neutron::agents::ovs':
#  local_ip => "${::ipaddress_eth1}",
#  enable_tunneling => true,
#}
#
#
#
#
##class { 'neutron::plugins::ovs':
##  tenant_network_type => 'vxlan',
##}
#
#class { 'neutron::agents::dhcp':
#  debug => true,
#}
#
#class { 'neutron::agents::l3':
#  debug => true,
#  use_namespaces => true,
#  #NOTE(rushiagr): default value of the below option is  true. we might need to
#  #understand how to configure it and understand it a bit more in the future
#  #handle_internal_only_routers => false,
#}

# ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
class { 'neutron::plugins::ml2':
  type_drivers          => ['vxlan'],
  tenant_network_types  => ['vxlan'],
  vxlan_group           => '239.1.1.1',
  mechanism_drivers     => ['openvswitch'],
  vni_ranges            => ['0:300']
}

include neutron::client
