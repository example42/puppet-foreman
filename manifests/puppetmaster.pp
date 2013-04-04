# = Class: foreman::puppetmaster
#
# This class is used to install foreman scripts on the
# puppetmaster for correct interaction with puppet
#
class foreman::puppetmaster {
  require foreman

  # ENC
  if $foreman::bool_enc == true {
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

  # Upload facts
  if ($foreman::bool_facts == true and $foreman::bool_storeconfigs == false) {
    file { 'push_facts.rb':
      ensure  => $foreman::manage_file,
      path    => "${foreman::puppet_config_dir}/push_facts.rb",
      mode    => $foreman::script_file_mode,
      owner   => $foreman::puppet_config_file_owner,
      group   => $foreman::puppet_config_file_group,
      require => $foreman::manage_require_package,
      notify  => $foreman::manage_service_autorestart,
      content => $foreman::manage_file_push_facts_content,
      replace => $foreman::manage_file_replace,
      audit   => $foreman::manage_audit,
    }

    # distribute cronjob randomly
    $tmp_cron_minute = fqdn_rand(5, 5)

    cron { "foreman::push_facts":
      ensure => $foreman::manage_file,
      command => "${foreman::puppet_config_dir}/push_facts.rb",
      minute => [
        $tmp_cron_minute,
        $tmp_cron_minute + 5,
        $tmp_cron_minute + 10,
        $tmp_cron_minute + 15,
        $tmp_cron_minute + 20,
        $tmp_cron_minute + 25,
        $tmp_cron_minute + 30,
        $tmp_cron_minute + 35,
        $tmp_cron_minute + 40,
        $tmp_cron_minute + 45,
        $tmp_cron_minute + 50,
        $tmp_cron_minute + 55]
    }
  }

  # Reports
  if $foreman::bool_reports == true {
    file { ["${foreman::rubysitedir}/puppet", "${foreman::rubysitedir}/puppet/reports"]:
      ensure => directory,
      audit  => $foreman::manage_audit,
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
