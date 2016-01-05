# == Class: gitlab_ci_multi_runner
#
# Install gitlab-ci multi runner (manage repository, package, service)
#
# === Parameters
#
# [*nice*]
#   A Niceness value for the Service to limit resources on shared machines.  Valid values from
#   -20 to +19.
#   Default: undef.
#
# [*env*]
#   Pass environment vars to the execs
#   Useful for a proxy or the like.
#   Default: undef.
#
# === Examples
#
#  include '::gitlab_ci_multi_runner'
#
class gitlab_ci_multi_runner (
    $nice = undef,
    $env = undef
) {
    $package_type = $::osfamily ? {
        'redhat' => 'rpm',
        'debian' => 'deb',
        default  => 'unknown',
    }
    $issuesLink = 'https://github.com/frankiethekneeman/puppet-gitlab-ci-multi-runner/issues'
    if $package_type == 'unknown' {
        fail("Target Operating system (${::operatingsystem}) not supported")
    }

    # Get the file created by the "repo adding" step.
    $repoLocation = $package_type ? {
        'rpm'   => '/etc/yum.repos.d/runner_gitlab-ci-multi-runner.repo',
        'deb'   => '/etc/apt/sources.list.d/runner_gitlab-ci-multi-runner.list',
        default => '/var',
        # Choose a file that will definitely be there so that we don't have
        # to worry about it running in the case of an unknown package_type.
    }

    $serviceFile = $package_type ? {
        'rpm'   => $::operatingsystemrelease ? {
            /^(5.*|6.*)/ => '/etc/init.d/gitlab-ci-multi-runner',
            default      => '/etc/systemd/system/gitlab-runner.service',
        },
        'deb'   => '/etc/init/gitlab-runner.conf',
        default => '/bin/true',
    }

    $version = $::osfamily ? {
        'redhat' => $::operatingsystemrelease ? {
            /^(5.*|6.*)/ => '0.4.2-1',
            default      => 'latest',
        },
        'debian' => 'latest',
        default  => 'There is no spoon',
    }

    $service = $version ? {
        '0.4.2-1' => 'gitlab-ci-multi-runner',
        default   => 'gitlab-runner',
    }

    $user = 'gitlab_ci_multi_runner'
    $home_path = "/home/${user}"
    $toml_file = $::gitlab_ci_multi_runner::version ? {
        /^0\.[0-4]\..*/ => "${home_path}/config.toml",
        default         => "${home_path}/.gitlab-runner/config.toml",
    }

    $repoScript = 'https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner'

    if $env { Exec { environment => $env } }

    # Ensure the gitlab_ci_multi_runner user exists.
    # TODO:  Investigate if this is necessary - install script may handle this.
    user { $user:
        ensure     => 'present',
        managehome => true,
    } ->
    # Add The repository to yum/deb-get
    exec { 'Add Repository':
        command  => "curl -L ${repoScript}/script.${package_type}.sh | bash",
        user     => root,
        provider => shell,
        creates  => $repoLocation,
    } ->
    # Install the package after the repo has been added.
    package { 'gitlab-ci-multi-runner':
        ensure => $version,
    } ->
    exec { 'Ensure Service':
        command  => "${service} install --user ${user} --config ${toml_file} --working-directory ${home_path}",
        user     => root,
        provider => shell,
        creates  => $serviceFile,
    } ->
    # Ensure that the service is running at all times.
    service { $service:
        ensure => 'running',
    }

    if $package_type == 'rpm' {
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
            case $serviceFile {
                '/etc/init.d/gitlab-ci-multi-runner': {
                    $niceval = $nice ? {
                        /^[-+]/ => $nice,
                        default => "+${nice}"
                    } #The nice value passed to the daemon function must have a leading sign
                    $sedSearch = ' daemon \([+-][0-9]\+ \)\?'
                    $sedReplace = " daemon ${niceval} "
                    exec {'Ensure Niceness':
                        command   => "sed -i 's/${sedSearch}/${sedReplace}/g' ${serviceFile}",
                        user      => root,
                        provider  => shell,
                        path      => $path,
                        require   => Exec['Ensure Service'],
                        #Only if the niceness isn't already set:
                        onlyif    => "! grep 'daemon ${niceval} ' ${serviceFile}",
                        notify    => Service[$service],
                        logoutput => true,
                    }
                }
                '/etc/systemd/system/gitlab-runner.service': {
                    $initCommand = "sed -i '/\\[Service\\]/a Nice=${nice}' ${serviceFile}"
                    $updateCommand = "sed -i 's/Nice=[+-]\\?[0-9]\\+/Nice=${nice}/g' ${serviceFile}"
                    $checkCommand = "grep 'Nice=[+-]\\?[0-9]\\+' ${serviceFile}"
                    exec {'Ensure Niceness':
                        command  => "${checkCommand} && ${updateCommand} || ${initCommand}",
                        user     => root,
                        provider => shell,
                        path     => $path,
                        require  => Exec['Ensure Service'],
                        #Only if the niceness isn't already set:
                        onlyif   => "! grep 'Nice=${nice} *\$' ${serviceFile}",
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
                    $sedSearch = ' start-stop-daemon \(-N [+-]\?[0-9]\+ \)\?'
                    $sedReplace = " start-stop-daemon -N ${nice} "
                    exec {'Ensure Niceness':
                        command  => "sed -i 's/${sedSearch}/${sedReplace}/g' ${serviceFile}",
                        user     => root,
                        provider => shell,
                        path     => $path,
                        require  => Exec['Ensure Service'],
                        onlyif   => "! grep 'start-stop-daemon -N ${nice} ' ${serviceFile}",
                        #Only if the niceness isn't already set:
                        notify   => Service[$service]
                    }
                }
                default: {
                    warning("Niceness not enabled for ${serviceFile}. Please report to ${issuesLink}")
                }
            }
        } else {
            fail("Invalid nice value: ${nice}")
        }
    }
}
