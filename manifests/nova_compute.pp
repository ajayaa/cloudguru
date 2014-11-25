class cloudguru::nova_compute {
  class { 'nova': }
  class { 'nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
  }
 
  class { 'nova::compute::libvirt':
    libvirt_virt_type     => 'qemu',
    #migration_support => true,
  }
  class { 'nova::network':
  #  fixed_range           => '11.1.1.1/24',
    private_interface     => 'eth2',
    enabled               => 'true',
  }
 
}

  
