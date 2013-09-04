# Class: foreman::params
#
# This class defines default parameters used by the main module class foreman
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to foreman class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class foreman::params {

  ### Module's specific variables
  $install_mode = 'server'

  $install_proxy = false

  $url = "https://${::fqdn}"

  # Perhaps this should be $puppet::params::server ?
  $puppet_server = "puppet.$::domain"

  # Perhaps this should be $puppet::params::config_dir ?
  $puppet_config_dir = '/etc/puppet'

  $puppet_modules_dir = '/etc/puppet/modules'

  # Perhaps this should be $puppet::params::data_dir ?
  $puppet_data_dir = '/var/lib/puppet'

  # Perhaps this should be $puppet::params:config_file_owner ?
  $puppet_config_file_owner = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'puppet',
    default                   => 'root',
  }

  # Perhaps this should be $puppet::params:config_file_group ?
  $puppet_config_file_group = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'puppet',
    default                   => 'root',
  }

  $bindaddress = '0.0.0.0'

  $environments = 'production'

  # Perhaps this should be $puppet::params::nodetool == 'foreman' ?
  $enc = true

  $reports = true

  $facts = true

  # Perhaps this should be $puppet::params::storeconfigs ?
  $storeconfigs = false

  $unattended = false

  $authentication = false

  # Perhaps this should be $puppet::params::passenger ?
  $passenger = false

  # The virtualhost servername for foreman to listen on
  $vhost_servername = $::fqdn

  # The virtualhost aliases for foreman to listen on. Comma separated
  $vhost_aliases = 'foreman'

  $ssl = true

  # If CA is specified, remote Foreman host will be verified in reports/ENC scripts
  $ssl_ca   = "${puppet_data_dir}/ssl/certs/ca.pem"
  # Used to authenticate to Foreman, required if require_ssl_puppetmasters is enabled
  $ssl_cert = "${puppet_data_dir}/ssl/certs/${::fqdn}.pem"
  $ssl_key  = "${puppet_data_dir}/ssl/private_keys/${::fqdn}.pem"

  $service_data_dir = '/var/lib/foreman'
  $service_ssl_dir  = "${service_data_dir}/ssl"
  $service_ssl_ca   = "${service_ssl_dir}/ca.pem"
  $service_ssl_cert = "${service_ssl_dir}/${::fqdn}.pem"
  $service_ssl_key  = "${service_ssl_dir}/${::fqdn}.key.pem"

  $service_user     = 'foreman'
  $service_group    = 'foreman'

  $proxy_data_dir = '/var/lib/foreman-proxy'
  $proxy_ssl_dir  = "${proxy_data_dir}/ssl"
  $proxy_ssl_ca   = "${proxy_ssl_dir}/ca.pem"
  $proxy_ssl_cert = "${proxy_ssl_dir}/${::fqdn}.pem"
  $proxy_ssl_key  = "${proxy_ssl_dir}/${::fqdn}.key.pem"

  $proxy_user     = 'foreman-proxy'
  $proxy_group    = 'foreman-proxy'

  $proxy_tftp_syslinux_dir = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/usr/lib/syslinux',
    default                   => '/usr/share/syslinux',
  }

  $proxy_tftp_servername = ''

  $proxy_dhcp_omapi_key = ''

  # Perhaps this should be $puppet::params::db ?
  $db = 'sqlite'

  $db_name = 'foreman'

  # Perhaps this should be $puppet::params::db_server ?
  $db_server = ''

  $db_user = ''

  $db_password = ''

  $db_path = ''

  $db_root_user = 'root'

  $db_root_password = ''

  $db_mysql_package = $::operatingsystem ? {
    default => 'foreman-mysql',
  }

  $db_postgresql_package = $::operatingsystem ? {
    default => 'foreman-postgresql',
  }

  $db_sqlite_package = $::operatingsystem ? {
    /(?i:Ubuntu)/ => 'foreman-sqlite3',
    default       => 'foreman-sqlite',
  }

  $basedir = $::operatingsystem ? {
    default => '/usr/share/foreman',
  }

  $preseed_file = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/var/cache/debconf/foreman.seeds',
    default => '/var/cache/foreman.seeds',
  }

  $template_database = ''

  $template_enc = ''

  $template_push_facts = ''

  $template_preseed = ''

  $template_passenger = ''

  $template_reports = ''

  $template_proxy_settings = ''

  $script_file_mode = $::operatingsystem ? {
    default => '0550',
  }

  ### Application related parameters
  
  $osver = split($::operatingsystemrelease, '[.]')
  $osver_maj = $osver[0]

  $repo_distro = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/       => $::lsbdistcodename,
    /(?i:redhat|centos|scientific|oraclelinux)/ => "el${osver_maj}",
    /(?i:fedora)/                   => "f${osver_maj}",
    default                         => 'UNKNOWN',
  }

  $repo_flavour = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/       => 'stable',
    /(?i:redhat|centos|scientific|oraclelinux)/ => 'releases/1.1',
    /(?i:fedora)/                   => 'releases/1.1',
    default                         => 'UNKNOWN',
  }

  $package = $::operatingsystem ? {
    default => 'foreman',
  }

  $proxy_package = $::operatingsystem ? {
    default => 'foreman-proxy',
  }

  $service = $::operatingsystem ? {
    default => 'foreman',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'ruby',
  }

  $process_args = $::operatingsystem ? {
    default => 'rails',
  }

  $process_user = $::operatingsystem ? {
    default => 'foreman',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/foreman',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/foreman/settings.yaml',
  }

  $proxy_config_file = $::operatingsystem ? {
    default => '/etc/foreman-proxy/settings.yml', # there is no 'a' in yaml!
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'foreman',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/foreman',
    default                   => '/etc/sysconfig/foreman',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/foreman.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/foreman',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/foreman',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/foreman/production.log',
  }

  $port = '3000'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $options = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false

}
