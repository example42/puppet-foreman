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

  apache::vhost { 'foreman':
    name           => $foreman::vhost_servername,
    serveraliases  => $foreman::vhost_aliases,
    port           => '80',
    priority       => '20',
    docroot        => "${foreman::basedir}/public/",
    ssl            => true,
    template       => $foreman::manage_file_passenger_path,
  }

  ### Firewall management, if enabled ( firewall => true )
  if $foreman::bool_firewall == true {
    firewall { 'foreman_http_80':
      source      => $foreman::firewall_src,
      destination => $foreman::firewall_dst,
      protocol    => 'tcp',
      port        => 80,
      action      => 'allow',
      direction   => 'input',
      tool        => $foreman::firewall_tool,
      enable      => $foreman::manage_firewall,
    }

    firewall { 'foreman_http_443':
      source      => $foreman::firewall_src,
      destination => $foreman::firewall_dst,
      protocol    => 'tcp',
      port        => 443,
      action      => 'allow',
      direction   => 'input',
      tool        => $foreman::firewall_tool,
      enable      => $foreman::manage_firewall,
    }
  }

}
