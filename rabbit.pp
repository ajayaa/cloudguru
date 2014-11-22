

# NOTE: need to run with this code for the first time. This code can and should
# be cleaned up ASAP.
include rabbitmq
rabbitmq_user { 'rabbituser':
  admin     => true,
  password  => 'rabbitpass',
}


rabbitmq_user_permissions { 'rabbituser@/':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}

