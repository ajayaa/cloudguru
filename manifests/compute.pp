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
