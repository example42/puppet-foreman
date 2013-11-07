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

  if any2bool($foreman::ssl) {
    apache::vhost { 'foreman':
      name           => $foreman::vhost_servername,
      serveraliases  => $foreman::vhost_aliases,
      port           => '443',
      priority       => '20',
      docroot        => "${foreman::basedir}/public/",
      ssl            => true,
      template       => $foreman::manage_file_passenger_path,
    }
  } else {
    apache::vhost { 'foreman':
      name           => $foreman::vhost_servername,
      serveraliases  => $foreman::vhost_aliases,
      port           => '80',
      priority       => '20',
      docroot        => "${foreman::basedir}/public/",
      ssl            => false,
      template       => $foreman::manage_file_passenger_path,
    }
  }

}
