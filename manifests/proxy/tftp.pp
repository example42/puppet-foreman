# Class foreman::proxy::tftp
#
class foreman::proxy::tftp {

  Class['tftp'] ->
  file {
    [
      "${::tftp::data_dir}/pxelinux.cfg",
      "${::tftp::data_dir}/boot"]:
      ensure  => directory,
      owner   => $foreman::proxy_user,
      mode    => 0644,
      require => [Package['foreman-proxy'], Package['tftp']],
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

  if ! defined(Package['wget']) { package { 'wget': ensure => present } }
  if ! defined(Package['syslinux']) { package { 'syslinux': ensure => present } }
}
