class foreman::proxy::puppetca {
  # This file has to be writable by the proxy to support modifying the autosign rules while installing the system
  file { "/etc/puppet/autosign.conf":
    ensure  => present,
    mode    => 0664,
    owner   => 'root',
    group   => $foreman::proxy_group,
    require => Package['foreman-proxy'];
  }
}