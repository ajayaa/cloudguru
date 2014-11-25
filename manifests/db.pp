class cloudguru::db {
  class { 'mysql':
    attempt_compatibility_mode => true,
    bind_address               => '192.168.100.10',
  }
#
#  class {'mysql::params':
#    mysqld        => {
#     bind_address => '192.168.100.10'
#     }
#     }
}
