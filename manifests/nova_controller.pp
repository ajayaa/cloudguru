class cloudguru::nova_controller {
  class { 'nova':
    database_connection => 'mysql://nova:nova@192.168.100.10/nova?charset=utf8',
    rabbit_userid       => 'rabbituser',
    rabbit_password     => 'rabbitpass',
    image_service       => 'nova.image.glance.GlanceImageService',
    glance_api_servers  => "${::fqdn}:9292",
    verbose             => true,
    rabbit_hosts                  => [
      "${::fqdn}:5672"
    ],
    mysql_module   => '2.2',
  }
  
  class { 'nova::api':
    admin_password    => 'nova',
    enabled           => true,
    auth_host         => "${::fqdn}",
    auth_protocol     => 'https', 
    admin_tenant_name => 'services',
  }
 
  class { 'nova::conductor':
    enabled       => true,
  }
  
  class { 'nova::scheduler':
    enabled       => true,
  }
  
  include nova::client

  class { 'mysql::server': }
  class { 'nova::db::mysql':
    password      => 'nova',
    mysql_module  => '2.2',
    allowed_hosts => '%',
  }

  class { 'nova::keystone::auth':
    password      => 'nova',
  }

}
