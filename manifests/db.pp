class cloudguru::db {
  class { 'mysql::server':
    override_options => { 'mysqld' => { 'bind-address' => '192.168.100.10' } },
    restart   => true,
  }
}
