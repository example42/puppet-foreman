# = Class: foreman::puppetmaster
#
# This class is used to install foreman scripts on the
# puppetmaster for correct interaction with puppet
#
class foreman::puppetmaster {

  require foreman 

  # ENC / Facts
  if $foreman::bool_enc == true
  or ($foreman::bool_facts == true
  and $foreman::bool_storeconfigs == false) {
    file { 'node.rb':
      ensure  => $foreman::manage_file,
      path    => "${foreman::puppet_config_dir}/node.rb",
      mode    => $foreman::script_file_mode,
      owner   => $foreman::puppet_config_file_owner,
      group   => $foreman::puppet_config_file_group,
      require => $foreman::manage_require_package,
      notify  => $foreman::manage_service_autorestart,
      content => $foreman::manage_file_enc_content,
      replace => $foreman::manage_file_replace,
      audit   => $foreman::manage_audit,
    }

    # ensure directories ${foreman::puppet_data_dir}/yaml
    # and ${foreman::puppet_data_dir}/yaml/foreman : puppet/puppet ; 640
  }

  # Reports
  if $foreman::bool_reports == true {
    file {
      ["${foreman::rubysitedir}/puppet", "${foreman::rubysitedir}/puppet/reports"]:
        ensure => directory,
        audit   => $foreman::manage_audit,
    }
    file { 'foreman.rb':
      ensure  => $foreman::manage_file,
      path    => "${foreman::rubysitedir}/puppet/reports/foreman.rb",
      mode    => $foreman::config_file_mode,
      owner   => $foreman::puppet_config_file_owner,
      group   => $foreman::puppet_config_file_group,
      require => $foreman::manage_require_package,
      notify  => $foreman::manage_service_autorestart,
      content => $foreman::manage_file_reports_content,
      replace => $foreman::manage_file_replace,
      audit   => $foreman::manage_audit,
    }
  }

}
