class cloudguru::rabbit {
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
}
