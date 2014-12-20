# Compute node

# NOTE: this needs fqdn for node1 set in /etc/hosts

Exec { logoutput => 'on_failure' }

class { 'nova':
  database_connection => 'mysql://nova:nova@192.168.100.10/nova?charset=utf8',
  rabbit_userid       => 'rabbituser',
  rabbit_password     => 'rabbitpass',
  image_service       => 'nova.image.glance.GlanceImageService',
  glance_api_servers  => "http://node1.example.com:9292",
  verbose             => true,
  rabbit_hosts                  => [
    "node1.example.com:5672"
  ],
  mysql_module   => '2.2',
}

class { 'nova::compute':
  enabled                       => true,
  vnc_enabled                   => true,
  neutron_enabled               => true,
}

class { 'nova::compute::libvirt':
  libvirt_virt_type     => 'qemu',
  #migration_support => true,
}

include nova::client

#class { 'nova::network':
#  fixed_range           => '11.1.1.1/24',
#  private_interface     => 'eth2',
#  enabled               => 'true',
#}

class { 'mysql::client': }
#class { 'nova::network::flatdhcp':
#  fixed_range           => '11.1.1.1/24',
#}
class { 'neutron':
  allow_overlapping_ips     => true, # Enables network namespaces
  verbose           => true,
  debug             => true,
  #TODO(rushiagr): see service_plugins option. More specifically, see if
  #'router' service plugin is required.
  #service_plugin    => 'router',
  rabbit_user       => 'rabbituser',
  rabbit_password   => 'rabbitpass',
  rabbit_host       => 'node1.example.com',
  log_file          => 'test_neutron_logfilename',
}

class { 'neutron::agents::ovs':
 local_ip => "${::ipaddress_eth1}",
 enable_tunneling => true,
}

class { 'neutron::plugins::ovs':
  tenant_network_type => 'vxlan',
#  network_vlan_ranges => 'physnet:100:200',
}
