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

class { 'nova::compute::neutron': }

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
  rabbit_user       => 'rabbituser',
  rabbit_password   => 'rabbitpass',
  rabbit_host       => 'node1.example.com',
}

class { 'neutron::server::notifications':
  nova_admin_tenant_name => 'services',
  nova_admin_username => 'nova',
  nova_url      => "http://node1.example.com:8774/v2",
  nova_admin_auth_url => "https://node1.example.com:5000/v2.0",
  nova_admin_password => 'nova',
}

class { 'neutron::agents::ml2::ovs':
  local_ip         => "${::ipaddress_eth1}",
  enable_tunneling => true,
  tunnel_types     => ['vxlan'],
}

class { 'neutron::plugins::ml2':
  type_drivers          => ['vxlan'],
  tenant_network_types  => ['vxlan'],
  vni_ranges            => ['1001:2000']
}

