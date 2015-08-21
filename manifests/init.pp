class gitlab_ci_multi_runner (
) {
    $package_type = $::osfamily ? {
        'redhat'  => 'rpm',
        'debian'  => 'deb',
        default => 'unknown',
    }

    if $package_type == 'unknown' {
        fail("Target Operating system (${::operatingsystem}) not supported")
    } elsif $package_type == 'deb' {
        warning("${::operatingsystem} support is still in Beta - please report any issues to the main repository at https://github.com/frankiethekneeman/puppet-gitlab-ci-multi-runner/issues")
    }

    # Get the file created by the "repo adding" step.
    $repoLocation = $package_type ? {
        'rpm'   => '/etc/yum.repos.d/runner_gitlab-ci-multi-runner.repo',
        'deb'   => '/etc/deb/sources.list.d/runner_gitlab-ci-multi-runner.list',
        default => '/var',
            # Choose a file that will definitely be there so that we don't have to worry about it running in the case
            # of an unknown package_manager type.
    }

    $serviceFile = $package_type ? {
        'rpm'   => $::operatingsystemrelease ? {
            /7.*/ => '/etc/systemd/system/gitlab-runner.service',
            default => '/etc/init.d/gitlab-runner'
        },
        'deb'   => '/etc/init/gitlab-runner.conf',
        default => '/bin/true'
    }

    $version = $::osfamily ? {
        'redhat' => $::operatingsystemrelease ? {
            /7.*/ => 'latest',
            default => '0.4.2-1'
        },
        'debian' => 'installed',
        default  => 'There is no spoon',
    }

    $user = 'gitlab_ci_multi_runner'

    # Ensure the gitlab_ci_multi_runner user exists.
    # TODO:  Investigate if this is necessary - the install script may handle this.
    user{ $user:
        ensure     => 'present',
        managehome => true,
    } ->
    # Add The repository to yum/deb-get
    exec {'Add Repository':
        command  => "curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.${package_type}.sh | bash",
        user     => root,
        provider => shell,
        creates  => $repoLocation,
    } ->
    # Install the package after the repo has been added.
    package { 'gitlab-ci-multi-runner':
        ensure => $version
    } ->
    exec {'Ensure Service':
        command  => 'gitlab-ci-multi-runner install',
        user     => root,
        provider => shell,
        creates  => $serviceFile,
    } ->
    # Ensure that the service is running at all times.
    service { 'gitlab-ci-multi-runner':
        ensure => 'running',
    }

    if $package_type == 'rpm' {
        exec { 'Yum Exclude Line':
            command  => 'echo exclude= >> /etc/yum.conf',
            onlyif   => "! grep '^exclude=' /etc/yum.conf",
            user     => root,
            provider => shell,
            require  => Exec['Ensure Service']
        }->
        exec { 'Yum Exclude gitlab-ci-multi-runner':
            command  => "sed -i 's/^exclude=.*$/& gitlab-ci-multi-runner/' /etc/yum.conf",
            onlyif   => "! grep '^exclude=.*gitlab-ci-multi-runner' /etc/yum.conf",
            user     => root,
            provider => shell,
        }
    }
}
