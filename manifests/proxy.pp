class foreman::proxy {
  include foreman
  include foreman::repository

  $url = "https://${::fqdn}:8443"

  package { 'foreman-proxy':
    ensure => $foreman::manage_package,
    name   => $foreman::proxy_package,
  }

  file {
    $foreman::proxy_data_dir:
      ensure  => directory,
      mode    => 0755,
      owner   => $foreman::proxy_user,
      group   => $foreman::proxy_group,
      require => Package['foreman-proxy'],
      notify  => Service['foreman-proxy'];

    $foreman::proxy_ssl_dir:
      ensure  => directory,
      mode    => 0755,
      owner   => $foreman::proxy_user,
      group   => $foreman::proxy_group,
      require => Package['foreman-proxy'],
      notify  => Service['foreman-proxy'];

    $foreman::proxy_ssl_ca:
      ensure  => present,
      source  => $foreman::ssl_ca,
      mode    => 0644,
      owner   => $foreman::proxy_user,
      group   => $foreman::proxy_group,
      require => Package['foreman-proxy'],
      notify  => Service['foreman-proxy'];

    $foreman::proxy_ssl_cert:
      ensure  => present,
      source  => $foreman::ssl_cert,
      mode    => 0644,
      owner   => $foreman::proxy_user,
      group   => $foreman::proxy_group,
      require => Package['foreman-proxy'],
      notify  => Service['foreman-proxy'];

    $foreman::proxy_ssl_key:
      ensure  => present,
      source  => $foreman::ssl_key,
      mode    => 0600,
      owner   => $foreman::proxy_user,
      group   => $foreman::proxy_group,
      require => Package['foreman-proxy'],
      notify  => Service['foreman-proxy'];
  }

  service { 'foreman-proxy':
    ensure    => $foreman::manage_proxy_service_ensure,
    enable    => $foreman::manage_proxy_service_enable,
    hasstatus => true,
    require   => Package['foreman-proxy'],
  }

  file { 'foreman-proxy-settings':
    ensure  => $foreman::manage_file,
    path    => $foreman::proxy_config_file,
    mode    => $foreman::config_file_mode,
    owner   => $foreman::config_file_owner,
    group   => $foreman::config_file_group,
    require => Package['foreman-proxy'],
    notify  => Service['foreman-proxy'],
    content => $foreman::manage_proxy_file_content,
    replace => $foreman::manage_file_replace,
    audit   => $foreman::manage_audit,
  }

  $features = [
    $::foreman::bool_proxy_feature_tftp ? {
      false => "''",
      true  => "'TFTP'"
    },
    $::foreman::bool_proxy_feature_dns ? {
      false => "''",
      true  => "'DNS'"
    },
    $::foreman::bool_proxy_feature_dhcp ? {
      false => "''",
      true  => "'DHCP'"
    },
    $::foreman::bool_proxy_feature_puppetca ? {
      false => "''",
      true  => "'PUPPET CA'"
    },
    $::foreman::bool_proxy_feature_puppet ? {
      false => "''",
      true  => "'Puppet'"
    },
    $::foreman::bool_proxy_feature_bmc ? {
      false => "''",
      true  => "'BMC'"
    } ]

  $where_feature = inline_template("<%= features.join(', ') %>")

  case $foreman::db {
    mysql   : {
      mysql::query { 'foreman-proxy':
        mysql_db       => $::foreman::db_name,
        mysql_query    => "INSERT INTO smart_proxies (name, url, created_at, updated_at) \
                           SELECT '${::fqdn}', '${url}', NOW(), NOW() FROM (SELECT 1) a WHERE NOT EXISTS \
                           (SELECT 1 FROM smart_proxies WHERE url = '${url}') LIMIT 1; \
                           INSERT INTO features_smart_proxies (smart_proxy_id, feature_id) \
                           SELECT LAST_INSERT_ID(), features.id FROM features WHERE \
                           features.name IN ('', ${where_feature}) AND ROW_COUNT() = 1",
        mysql_user     => $::foreman::db_user,
        mysql_password => $::foreman::db_password,
        mysql_host     => $::foreman::db_server,
      }

      # Todo: Something with exported resources?
    }
    default : {
      info("The foreman-proxy functionality is only supported with Mysql, for now add the proxy manually as '${url}'")
    }
  }
}