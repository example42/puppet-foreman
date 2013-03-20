# Class: foreman::postgresql
#
# This class configures postgresql for foreman installation
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by foreman
#
class foreman::postgresql inherits foreman {
  package { 'foreman-db':
    ensure => $foreman::manage_package,
    name   => $foreman::db_postgresql_package,
  }

  case $foreman::db_server {
    '', 'localhost', '127.0.0.1' : {
      postgresql::dbcreate { $foreman::db_name:
        role     => $foreman::db_user,
        password => $foreman::db_password,
        address  => $foreman::db_server,
        before   => Package['foreman-db'],
      }
    }
    default                  : {
      @@postgresql::dbcreate { $foreman::db_name:
        role     => $foreman::db_user,
        password => $foreman::db_password,
        address  => $foreman::db_server,
        tag      => "mysql_grants_${foreman::db_server}",
      }
    }
  }
}
