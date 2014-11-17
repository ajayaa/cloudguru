# Example file for apache only. Works with and without SSL endpoints.

class { 'apache':
  default_vhost => false,

  # If you uncomment these following two lines, all the default things like
  # modules will be disabled.
  #default_mods        => false,
  #default_confd_files => false,

  default_ssl_key => '/home/vagrant/ssl/server2.key',
  default_ssl_cert => '/home/vagrant/ssl/server2.crt',

}

apache::vhost { 'first':
  port => '80',
  docroot => '/var/www/first',
}
apache::vhost { 'second':
  port => '88',
  docroot => '/var/www/html',
}
apache::vhost { 'ssl':
  port => '443',
  docroot => '/var/www/ssl',
  ssl => true,
}
apache::vhost { 'ssltwo':
  port => '4433',
  docroot => '/var/www/ssltwo',
  ssl => true,
}
