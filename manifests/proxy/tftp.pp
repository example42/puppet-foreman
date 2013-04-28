class foreman::proxy::tftp {
  include ::tftp

  file {
    [
      "${::tftp::data_dir}/pxelinux.cfg",
      "${::tftp::data_dir}/boot"]:
      ensure  => directory,
      owner   => $foreman::proxy_user,
      mode    => 0644,
      require => [Package['foreman'], Package['tftp']],
      recurse => true;

    "${::tftp::data_dir}/pxelinux.0":
      source  => "${foreman::proxy_tftp_syslinux_dir}/pxelinux.0",
      owner   => $foreman::proxy_user,
      mode    => 0644,
      require => Package['syslinux'];

    "${::tftp::data_dir}/menu.c32":
      source  => "${foreman::proxy_tftp_syslinux_dir}/menu.c32",
      owner   => $foreman::proxy_user,
      mode    => 0644,
      require => Package['syslinux'];

    "${::tftp::data_dir}/chain.c32":
      source  => "${foreman::proxy_tftp_syslinux_dir}/chain.c32",
      owner   => $foreman::proxy_user,
      mode    => 0644,
      require => Package['syslinux'];
  }

  # meh
  package { ['wget', 'syslinux']: ensure => installed }
}