class cloudguru::image {

  class { 'glance::api':
    verbose           => true,
    auth_host         => "${::fqdn}",
    auth_port         => '5000',
    auth_protocol     => 'https',
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => 'glance',
    sql_connection    => 'mysql://glance:glance@192.168.100.10/glance',
    mysql_module   => '2.2',
  }
  
  class { 'glance::registry':
    verbose           => true,
    auth_host         => "${::fqdn}",
    auth_port         => '5000',
    auth_protocol     => 'https',
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => 'glance',
    sql_connection    => 'mysql://glance:glance@192.168.100.10/glance',
    mysql_module   => '2.2',
  }
  
  class { 'glance::backend::file': }

  class { 'glance::notify::rabbitmq':
    rabbit_userid                 => 'rabbituser',
    rabbit_password               => 'rabbitpass',
    rabbit_hosts                  => [
      "${::fqdn}:5672"
    ],
    rabbit_use_ssl                => false,
  }

  class { 'glance::db::mysql':
    password      => 'glance',
    mysql_module   => '2.2',
    allowed_hosts => '%',
  }
  
  class { 'glance::keystone::auth':
    password         => 'glance',
    email            => 'glance@example.com',
    public_address   => "${::fqdn}",
    admin_address    => "${::fqdn}",
    internal_address => "${::fqdn}",
    region           => 'RegionOne',
  }

}
