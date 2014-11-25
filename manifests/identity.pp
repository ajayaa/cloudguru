class cloudguru::identity{
  class { 'keystone':
    verbose        => true,
    debug          => true,
    database_connection => 'mysql://keystone:keystone@192.168.100.10/keystone',
    catalog_type   => 'sql',
    admin_token    => 'admin_token',
    mysql_module   => '2.2',
  
  # Default is PKI token for Icehouse. Here we're changing it to UUID
    token_provider => 'keystone.token.providers.uuid.Provider',
  
  # NOTE(rushiagr): Do not set this to true if apache is enabled, as in this
  # site.pp. If set to true, then keystone will try to run on both apache as well
  # as WSGI servers, and this will lead to "Port/address in use" errors.
    enabled        => false,
    enable_ssl     => true,
    admin_endpoint => "https://${::fqdn}:35357/v2.0/",
    public_endpoint => "https://${::fqdn}:5000/v2.0/",
  }
  
  class { 'keystone::roles::admin':
    admin_tenant  => 'admin',
    email         => 'rushi.agr@gmail.com',
    password      => 'ChangeMe',
  }
  class { 'keystone::endpoint':
    public_url => "https://${::fqdn}:5000",
    admin_url  => "https://${::fqdn}:35357",
    internal_url => "https://${::fqdn}:35357",
  }

  class { 'keystone::db::mysql':
    password => 'keystone',
    mysql_module   => '2.2',
    allowed_hosts => '%',
  }

  include apache
  class { 'keystone::wsgi::apache':
    ssl => true,
    ssl_cert => '/home/vagrant/cloudguru/ssl/fake.crt',
    ssl_key => '/home/vagrant/cloudguru/ssl/fake.key',
  }
}

