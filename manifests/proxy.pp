class foreman::proxy {

  include foreman
  include foreman::repository

  $url = "http://${::fqdn}:8443"

  package { 'foreman-proxy':
    ensure       => $foreman::manage_package,
    name         => $foreman::proxy_package,
#    responsefile => $foreman::proxy_preseed_file,
#    require      => File['foreman.seeds'],
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
    }

  ]

  $where_feature = inline_template("<%= features.join(', ') %>")

  case $foreman::db {
    mysql: {
      mysql::query { 'foreman-proxy':
        mysql_db       => $::foreman::db_name,
        mysql_query    => "INSERT INTO smart_proxies (name, url, created_at, updated_at) \
                           SELECT '${::fqdn}', '${url}', NOW(), NOW() FROM (SELECT 1) a WHERE NOT EXISTS \
                           (SELECT 1 FROM smart_proxies WHERE url = '${url}') LIMIT 1; \
                           INSERT INTO features_smart_proxies (smart_proxy_id, feature_id) \
                           SELECT LAST_INSERT_ID(), features.id FROM features WHERE \
                           features.name IN ('', ${where_feature}) AND LAST_INSERT_ID() != 0",
        mysql_user     => $::foreman::db_user,
        mysql_password => $::foreman::db_password,
        mysql_host     => $::foreman::db_server
      }

    }
    default: { raise Puppet::ParseError, "Unknown Zend Server version specified." }
  }


}