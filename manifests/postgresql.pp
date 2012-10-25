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
    ensure  => $foreman::manage_package,
    name    => $foreman::db_postgresql_package,
  }
}
