# Class: foreman::mysql
#
# This class configures mysql for foreman installation
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by foreman
#
class foreman::mysql inherits foreman {

  package { 'foreman-db':
    ensure  => $foreman::manage_package,
    name    => $foreman::db_mysql_package,
  }

  # Grants management
  case $foreman::db_server {
    '', 'localhost','127.0.0.1': {
      mysql::grant { "foreman_server_grants_${::fqdn}":
        mysql_db         => $foreman::db_name,
        mysql_user       => $foreman::db_user,
        mysql_password   => $foreman::db_password,
        mysql_privileges => 'ALL',
        mysql_host       => $foreman::db_server,
      }
    }
    default: {
      # Automanagement of Mysql grants on external servers
      # requires StoredConfigs.
      @@mysql::grant { "foreman_server_grants_${::fqdn}":
        mysql_db         => $foreman::db_name,
        mysql_user       => $foreman::db_user,
        mysql_password   => $foreman::db_password,
        mysql_privileges => 'ALL',
        mysql_host       => $::fqdn,
        tag              => "mysql_grants_${foreman::db_server}",
      }
    }
  }

}

