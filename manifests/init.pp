# == Class: rootsh
#
# Module to manage rootsh program
#
class rootsh (
  $ensure                = 'present',
  $package_name          = 'rootsh',
  $package_provider      = undef,
  $from_source           = false,
  $source_file           = 'UNSET',
  $log_path              = 'USE_DEFAULTS',
  $log_owner             = 'root',
  $log_group             = 'root',
  $log_mode              = '0755',
  $rsyslog_conf_content  = 'MANDATORY',
) {

  include rsyslog

  validate_re($ensure, '^(present|absent)$',
    "rootsh::ensure is <${ensure}>. Must be present or absent.")

  validate_string($package_name)

  if $package_provider != undef {
    validate_string($package_provider)
  }

  $from_source_type = type($from_source)

  case $from_source_type {
    'string': {
      $from_source_real = str2bool($from_source)
    }
    'boolean': {
      $from_source_real = $from_source
    }
    default: {
      fail("rootsh::from_source must be of type boolean or string. Detected type is <${from_source_type}>.")
    }
  }

  if $source_file != 'UNSET' {
    validate_string($source_file)
  }

  case $::kernel {
    'Linux': {
      $default_log_path = '/var/log/rootsh'
    }
    'SunOS': {
      $default_log_path = '/var/adm/rootsh'

      if $from_source {
        fail("rootsh from source does not support kernel SunOS. Detected kernel is <${::kernel}>.") 
      }
    }
    default: {
      fail("rootsh only supports kernel Linux and SunOS. Detected kernel is <${::kernel}>.")
    }
  }

  if $log_path == 'USE_DEFAULTS' {
    $log_path_real = $default_log_path
  } else {
    $log_path_real = $log_path
  }

  validate_string($log_owner)
  validate_string($log_group)
  validate_re($log_mode, '^(\d){4}$',
    "rootsh::log_mode is <${log_mode}>. Must be in four digit octal notation.")

  if $rsyslog_conf_content == 'MANDATORY' or $rsyslog_conf_content == '' {
    validate_string($rsyslog_conf_content)
  }

  if $from_source_real {
    if $source_file == 'UNSET' {
      fail("rootsh::source_file should be set.")
    }

    file { 'rootsh_source_file':
      ensure => file,
      path   => '/usr/local/src/rootsh.tar.gz',
      source => $source_file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    package { 'rootsh_requierement_packages':
      ensure   => present,
      name     => [ 'gcc', 'make' ],
      provider => $provider,
    }

    exec { 'rootsh_compile_source':
      path    => "/usr/bin:/usr/sbin:/bin",
      command => "tar xzf rootsh.tar.gz && rootshdir=`ls -d rootsh* | grep -v gz | sort | head -n 1` ; cd \${rootshdir} && ./configure --with-logdir=${log_path_real} && make && make install",
      cwd     => '/usr/local/src',
      unless  => 'test -f /usr/local/bin/rootsh',
    }

    File['rootsh_source_file'] -> Package['rootsh_requierement_packages'] -> Exec['rootsh_compile_source']
  }
  else {
    package { 'rootsh_package':
      ensure   => $ensure,
      name     => $name,
      provider => $provider,
    }
  }

  file { 'rootsh_log_dir':
    ensure  => directory,
    path    => $log_path_real,
    owner   => $log_owner,
    group   => $log_group,
    mode    => $log_mode,
  }

  if $ensure != 'absent' {
    $rsyslog_conf_ensure = 'file'
  } else {
    $rsyslog_conf_ensure = $ensure
  }

  rsyslog::fragment { 'rootsh':
    ensure  => $rsyslog_conf_ensure,
    content => $rsyslog_conf_content,
  }
}
