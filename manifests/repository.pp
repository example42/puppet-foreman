# Class: foreman::repository
#
# This class installs foreman repositories.
# Required for installation based on package
#
# == Variables
#
# Refer to foreman class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by foreman main class.
# This class uses default file and exec defines to avoid more
# Example42 dependencies (sigh)
#
class foreman::repository inherits foreman {

  case $::operatingsystem {

    redhat,centos,fedora,Scientific: {
      file { 'foreman.repo':
        path    => '/etc/yum.repos.d/foreman.repo',
        content => template('foreman/foreman.repo'),
      }
    }

    Debian,Ubuntu: {
      $dist = $::operatingsystem ? {
        'Debian' => 'squeeze',
        'Ubuntu' => 'precise',
      }
      file { '/etc/apt/sources.list.d/foreman.list':
        content => "deb http://deb.theforeman.org/ ${dist} stable\n"
      }
      ~>
      exec { 'foreman-key':
        command     => '/usr/bin/wget -q http://deb.theforeman.org/foreman.asc -O- | /usr/bin/apt-key add -',
        refreshonly => true
      }
      ~>
      exec { 'update-apt':
        command     => '/usr/bin/apt-get update',
        refreshonly => true
      }
    }
    default: { fail("${::hostname}: This module does not support operatingsystem ${::operatingsystem}") }
  }
}
