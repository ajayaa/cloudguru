class { 'glance::api':
  verbose           => true,
  auth_host         => '192.168.100.1',
  auth_url          => 'http://192.168.100.1:5000/v2.0',
  auth_port         => '5000',
  keystone_tenant   => 'service',
  keystone_user     => 'glance',
  keystone_password => '123',
  sql_connection    => 'mysql://root:123@192.168.100.1/glance',
}

class { 'glance::registry':
  verbose           => true,
  auth_host         => '192.168.100.1',
  auth_port         => '5000',
  keystone_tenant   => 'service',
  keystone_user     => 'glance',
  keystone_password => '123',
  sql_connection    => 'mysql://root:123@192.168.100.1/glance',
}

class { 'glance::backend::file': }

class { 'glance::notify::rabbitmq':
  rabbit_password               => '123',
  rabbit_userid                 => 'guest',
  rabbit_hosts                  => [
    '192.168.100.1:5672'
  ],
  rabbit_use_ssl                => false,
}
