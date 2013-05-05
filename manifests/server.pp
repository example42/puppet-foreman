# = Class: foreman::server
#
# This installs foreman server
#
class foreman::server {
  include foreman

  # ## Managed resources
  file { 'foreman.seeds':
    ensure  => $foreman::manage_file,
    path    => $foreman::preseed_file,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => $foreman::manage_file_preseed_content,
    replace => $foreman::manage_file_replace,
    audit   => $foreman::manage_audit,
  }

  require foreman::repository

  package { 'foreman':
    ensure       => $foreman::manage_package,
    name         => $foreman::package,
    responsefile => $foreman::preseed_file,
    require      => File['foreman.seeds'],
  }

  case $foreman::db {
    mysql      : { include foreman::mysql }
    postgresql : { include foreman::postgresql }
    default    : { include foreman::sqlite }
  }

  service { 'foreman':
    ensure    => $foreman::manage_service_ensure,
    name      => $foreman::service,
    enable    => $foreman::manage_service_enable,
    hasstatus => $foreman::service_status,
    pattern   => $foreman::process,
    require   => Package['foreman', 'foreman-db'],
  }

  file { 'settings.yaml':
    ensure  => $foreman::manage_file,
    path    => $foreman::config_file,
    mode    => $foreman::config_file_mode,
    owner   => $foreman::config_file_owner,
    group   => $foreman::config_file_group,
    require => Package['foreman'],
    notify  => $foreman::manage_service_autorestart,
    source  => $foreman::manage_file_source,
    content => $foreman::manage_file_content,
    replace => $foreman::manage_file_replace,
    audit   => $foreman::manage_audit,
  }

  file { 'database.yml':
    ensure  => $foreman::manage_file,
    path    => "${foreman::config_dir}/database.yml",
    mode    => $foreman::config_file_mode,
    owner   => $foreman::config_file_owner,
    group   => $foreman::config_file_group,
    require => Package['foreman'],
    notify  => $foreman::manage_service_autorestart,
    content => $foreman::manage_file_database_content,
    replace => $foreman::manage_file_replace,
    audit   => $foreman::manage_audit,
  }

  # The whole foreman configuration directory can be recursively overriden
  if $foreman::source_dir {
    file { 'foreman.dir':
      ensure  => directory,
      path    => $foreman::config_dir,
      require => Package['foreman'],
      notify  => $foreman::manage_service_autorestart,
      source  => $foreman::source_dir,
      recurse => true,
      purge   => $foreman::bool_source_dir_purge,
      replace => $foreman::manage_file_replace,
      audit   => $foreman::manage_audit,
    }
  }

  # Unattended
  package { 'foreman-libvirt':
    ensure  => $foreman::manage_libvirt_package,
    require => Package['foreman'],
    notify  => $foreman::manage_service_autorestart;
  }

  # Passenger / SSL
  if $foreman::bool_passenger == true {
    include foreman::passenger
  }

  # Storeconfigs
  if $foreman::bool_storeconfigs == true {
    exec { 'db-migrate':
      command     => '/usr/bin/rake RAILS_ENV=production db:migrate',
      cwd         => $foreman::basedir,
      require     => Service['foreman'],
      subscribe   => Package['foreman'],
      refreshonly => true,
    }
  }

  if $foreman::bool_ssl {
    file {
      $foreman::service_data_dir:
        ensure  => directory,
        mode    => 0755,
        owner   => $foreman::service_user,
        group   => $foreman::service_group,
        require => Package['foreman'],
        notify  => $foreman::manage_service_autorestart;

      $foreman::service_ssl_dir:
        ensure => directory,
        mode   => 0755,
        owner  => $foreman::service_user,
        group  => $foreman::service_group,
        require => Package['foreman'],
        notify => $foreman::manage_service_autorestart;

      $foreman::service_ssl_ca:
        ensure => present,
        source => $foreman::ssl_ca,
        mode   => 0644,
        owner  => $foreman::service_user,
        group  => $foreman::service_group,
        require => Package['foreman'],
        notify => $foreman::manage_service_autorestart;

      $foreman::service_ssl_cert:
        ensure => present,
        source => $foreman::ssl_cert,
        mode   => 0644,
        owner  => $foreman::service_user,
        group  => $foreman::service_group,
        require => Package['foreman'],
        notify => $foreman::manage_service_autorestart;

      $foreman::service_ssl_key:
        ensure => present,
        source => $foreman::ssl_key,
        mode   => 0600,
        owner  => $foreman::service_user,
        group  => $foreman::service_group,
        require => Package['foreman'],
        notify => $foreman::manage_service_autorestart;
    }
  }

  # ## Include custom class if $my_class is set
  if $foreman::my_class {
    include $foreman::my_class
  }

  # ## Provide puppi data, if enabled ( puppi => true )
  if $foreman::bool_puppi == true {
    $classvars = get_class_args()

    puppi::ze { 'foreman':
      ensure    => $foreman::manage_file,
      variables => $classvars,
      helper    => $foreman::puppi_helper,
    }
  }

  # ## Service monitoring, if enabled ( monitor => true )
  if $foreman::bool_monitor == true {
    monitor::port { "foreman_${foreman::protocol}_${foreman::port}":
      protocol => $foreman::protocol,
      port     => $foreman::port,
      target   => $foreman::monitor_target,
      tool     => $foreman::monitor_tool,
      enable   => $foreman::manage_monitor,
    }

    monitor::process { 'foreman_process':
      process  => $foreman::process,
      service  => $foreman::service,
      pidfile  => $foreman::pid_file,
      user     => $foreman::process_user,
      argument => $foreman::process_args,
      tool     => $foreman::monitor_tool,
      enable   => $foreman::manage_monitor,
    }
  }

  # ## Firewall management, if enabled ( firewall => true )
  if $foreman::bool_firewall == true {
    firewall { "foreman_${foreman::protocol}_${foreman::port}":
      source      => $foreman::firewall_src,
      destination => $foreman::firewall_dst,
      protocol    => $foreman::protocol,
      port        => $foreman::port,
      action      => 'allow',
      direction   => 'input',
      tool        => $foreman::firewall_tool,
      enable      => $foreman::manage_firewall,
    }
  }

  # ## Debugging, if enabled ( debug => true )
  if $foreman::bool_debug == true {
    file { 'debug_foreman':
      ensure  => $foreman::manage_file,
      path    => "${settings::vardir}/debug-foreman",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'
      ),
    }
  }

}
