# == Class: gitlab_ci_multi_runner
#
# Install gitlab-ci multi runner (manage repository, package, service)
#
# === Parameters
#
# [*nice*]
#   A Niceness value for the Service to limit resources on shared machines.
#   Valid values from -20 to +19.
#   Default: undef.
#
# [*version*]
#   A version for the gitlab-ci-multi-runner package. This can be to a specfic
#   version number, present (if you don't want Puppet to update it for you) or
#   latest.
#
#   The version of the package will always be set to v0.4.2 for RHEL5 and RHEL
#   6 derivatives.
#   Default: latest
#
# [*env*]
#   Pass environment vars to the execs
#   Useful for a proxy or the like.
#   Default: undef.
#
# [*manage_user*]
#   Do you want to manage the user
#   You may want to turn off if you use root.
#   Default: true.
#
# [*user*]
#   The user to manage or run as
#   You may want to use root.
#   Default: gitlab_ci_multi_runner.
#
# === Examples
#
#  include '::gitlab_ci_multi_runner'
#
class gitlab_ci_multi_runner (
    $nice = undef,
    $env = undef,
    $manage_user = true,
    $user = 'gitlab_ci_multi_runner',
    $version = 'latest'
) {
    $package_type = $::osfamily ? {
        'redhat' => 'rpm',
        'debian' => 'deb',
        default  => 'unknown',
    }
    $issues_link = 'https://github.com/frankiethekneeman/puppet-gitlab-ci-multi-runner/issues'
    if $package_type == 'unknown' {
        fail("Target Operating system (${::operatingsystem}) not supported")
    }

    # Get the file created by the "repo adding" step.
    $repo_location = $package_type ? {
        'rpm'   => '/etc/yum.repos.d/runner_gitlab-runner.repo',
        'deb'   => '/etc/apt/sources.list.d/runner_gitlab-runner.list',
        default => '/var',
        # Choose a file that will definitely be there so that we don't have
        # to worry about it running in the case of an unknown package_type.
    }

    $service_file = $package_type ? {
        'rpm'   => $::operatingsystemrelease ? {
            /^(5.*|6.*)/ => '/etc/init.d/gitlab-ci-multi-runner',
            default      => '/etc/systemd/system/gitlab-runner.service',
        },
        'deb'   => $::operatingsystemrelease ? {
            /^(14.*|7.*)/ => '/etc/init/gitlab-runner.conf',
            default => '/etc/systemd/system/gitlab-runner.service',
        },
        default => '/bin/true',
    }

    if !$version {
        $theVersion = $::osfamily ? {
            'redhat' => $::operatingsystemrelease ? {
                /^(5.*|6.*)/ => '0.4.2-1',
                default      => 'latest',
            },
            'debian' => 'latest',
            default  => 'There is no spoon',
        }
    } else {
        $theVersion = $version

    }

    $service = $theVersion ? {
        '0.4.2-1' => 'gitlab-ci-multi-runner',
        default   => 'gitlab-runner',
    }

    $home_path = $user ? {
        'root'  => '/root',
        default => "/home/${user}",
    }

    $toml_path = $user ? {
        'root'  => '/etc/gitlab-runner',
        default => $::gitlab_ci_multi_runner::version ? {
            /^0\.[0-4]\..*/ => $home_path,
            default         => "${home_path}/.gitlab-runner",
        },
    }

    $toml_file = "${toml_path}/config.toml"

    $repo_script = 'https://packages.gitlab.com/install/repositories/runner/gitlab-runner'

    if $env { Exec { environment => $env } }

    # Ensure the gitlab_ci_multi_runner user exists.
    # TODO:  Investigate if this is necessary - install script may handle this.
    if $manage_user {
      user { $user:
          ensure     => 'present',
          managehome => true,
          before     => Exec['Add Repository'],
      }
    }
    # Add The repository to yum/deb-get
    exec { 'Add Repository':
        command  => "curl -L ${repo_script}/script.${package_type}.sh | bash",
        user     => root,
        provider => shell,
        creates  => $repo_location,
    }
    if ($package_type == 'deb') {
        file { '/etc/apt/preferences.d/pin-gitlab-runner.pref':
            ensure  => 'present',
            mode    => '0644',
            content => 'Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001',
            require => Exec['Add Repository']
        }
    }

    # Install the package after the repo has been added.
    package { 'gitlab-runner':
        ensure  => $theVersion,
        require => Exec['Add Repository']
    }
    exec { 'Uninstall Misconfigured Service':
        command  => "service ${service} stop; ${service} uninstall",
        user     => root,
        provider => shell,
        unless   => "grep '${toml_file}' ${service_file}",
        require  => Package['gitlab-runner']
    }
    exec { 'Ensure Service':
        command  => "${service} install --user ${user} --config ${toml_file} --working-directory ${home_path}",
        user     => root,
        provider => shell,
        creates  => $service_file,
        require  => Exec['Uninstall Misconfigured Service']
    }
    file { 'Ensure .gitlab-runner directory is owned by correct user':
        path    => $toml_path,
        owner   => $user,
        recurse => true,
        require => Exec['Ensure Service']
    }
    # Ensure that the service is running at all times.
    service { $service:
        ensure  => 'running',
        require => File['Ensure .gitlab-runner directory is owned by correct user']
    }

    # Stop the package being updated where a specific version is specified
    if ! ($theVersion in ['latest', 'present']) {
        exec { 'Yum Exclude Line':
            command  => 'echo exclude= >> /etc/yum.conf',
            onlyif   => "! grep '^exclude=' /etc/yum.conf",
            user     => root,
            provider => shell,
            require  => Exec['Ensure Service'],
        }->
        exec { 'Yum Exclude gitlab-ci-multi-runner':
            command  => "sed -i 's/^exclude=.*$/& gitlab-ci-multi-runner/' /etc/yum.conf",
            onlyif   => "! grep '^exclude=.*gitlab-ci-multi-runner' /etc/yum.conf",
            user     => root,
            provider => shell,
        }
    }
    if $nice != undef {
        if $nice =~ /^(-20|[-+]?1?[0-9])$/ {
            $path = '/bin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/sbin'
            case $service_file {
                '/etc/init.d/gitlab-ci-multi-runner': {
                    $niceval = $nice ? {
                        /^[-+]/ => $nice,
                        default => "+${nice}"
                    } #The nice value passed to the daemon function must have a leading sign
                    $sed_search = ' daemon \([+-][0-9]\+ \)\?'
                    $sed_replace = " daemon ${niceval} "
                    exec {'Ensure Niceness':
                        command   => "sed -i 's/${sed_search}/${sed_replace}/g' ${service_file}",
                        user      => root,
                        provider  => shell,
                        path      => $path,
                        require   => Exec['Ensure Service'],
                        #Only if the niceness isn't already set:
                        onlyif    => "! grep 'daemon ${niceval} ' ${service_file}",
                        notify    => Service[$service],
                        logoutput => true,
                    }
                }
                '/etc/systemd/system/gitlab-runner.service': {
                    $init_command = "sed -i '/\\[Service\\]/a Nice=${nice}' ${service_file}"
                    $update_command = "sed -i 's/Nice=[+-]\\?[0-9]\\+/Nice=${nice}/g' ${service_file}"
                    $check_command = "grep 'Nice=[+-]\\?[0-9]\\+' ${service_file}"
                    exec {'Ensure Niceness':
                        command  => "${check_command} && ${update_command} || ${init_command}",
                        user     => root,
                        provider => shell,
                        path     => $path,
                        require  => Exec['Ensure Service'],
                        #Only if the niceness isn't already set:
                        onlyif   => "! grep 'Nice=${nice} *\$' ${service_file}",
                    } ~>
                    exec {'Reload Service Info': #Because Puppet won't automagically do this
                        command     => 'systemctl daemon-reload',
                        user        => root,
                        provider    => shell,
                        path        => $path,
                        refreshonly => true,
                        notify      => Service[$service]
                    }
                }
                '/etc/init/gitlab-runner.conf': {
                    $sed_search = ' start-stop-daemon \(-N [+-]\?[0-9]\+ \)\?'
                    $sed_replace = " start-stop-daemon -N ${nice} "
                    exec {'Ensure Niceness':
                        command  => "sed -i 's/${sed_search}/${sed_replace}/g' ${service_file}",
                        user     => root,
                        provider => shell,
                        path     => $path,
                        require  => Exec['Ensure Service'],
                        onlyif   => "! grep 'start-stop-daemon -N ${nice} ' ${service_file}",
                        #Only if the niceness isn't already set:
                        notify   => Service[$service]
                    }
                }
                default: {
                    warning("Niceness not enabled for ${service_file}. Please report to ${issues_link}")
                }
            }
        } else {
            fail("Invalid nice value: ${nice}")
        }
    }
}
