# Class: foreman::sqlite
#
# This class configures sqlite for foreman installation
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by foreman
#
class foreman::sqlite inherits foreman {
  package { 'foreman-db':
    ensure  => $foreman::manage_package,
    name    => $foreman::db_sqlite_package,
  }
}
