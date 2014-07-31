#
# Class foreman::passenger
#
# Installs and configures passenger for Foreman
#
class foreman::passenger {
  require foreman

  include apache::ssl
  include apache::passenger

  file { "${foreman::basedir}/config/environment.rb":
    owner   => $foreman::process_user,
    require => Class['foreman'],
  }

  $manage_apache_vhost_port = $foreman::bool_ssl ? {
    true  => '443',
    false => '80',
  }
  apache::vhost { 'foreman':
    name           => $foreman::vhost_servername,
    serveraliases  => $foreman::vhost_aliases,
    port           => $manage_apache_vhost_port,
    priority       => '20',
    docroot        => "${foreman::basedir}/public/",
    ssl            => $foreman::bool_ssl,
    template       => $foreman::manage_file_passenger_path,
  }

}
