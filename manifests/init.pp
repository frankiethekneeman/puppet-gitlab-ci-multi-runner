class gitlab_ci_multi_runner (
    #The package manager version to add the repository for - RPM or APT. Currently, only RPM is supported because it's the only system 
    #I have to test for.

    $package_manager    = 'rpm'
    #TODO:  Get $package_manager from environment, not from parameter.
) {

    # Get the file created by the "repo adding" step.
    # This may need to be refactored to use "onlyif" tests instead of using "creates" when APT support is built out.
    $repoLocation = $package_manager ? {
        'rpm' => "/etc/yum.repos.d/runner_gitlab-ci-multi-runner.repo",
        #TODO:  Add repo Location for APT
        default => '/var',
            # Choose a file that will definitely be there so that we don't have to worry about it running in the case
            # of an unknown package_manager type.
    }

    $user = 'gitlab_ci_multi_runner'

    # Ensure the gitlab_ci_multi_runner user exists.
    # TODO:  Investigate if this is necessary - the install script may handle this.
    user{ $user:
        ensure     => "present",
        managehome => "true",
    } ->
    # Add The repository to yum/apt-get
    exec {"Add Repository":
        command  => "curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.${package_manager}.sh | bash",
        user     => root,
        provider => shell,
        creates  => $repoLocation,
    } ->
    # Install the package after the repo has been added.
    package { 'gitlab-ci-multi-runner':
        ensure => installed
    } ->
    # Ensure that the service is running at all times.
    service { "gitlab-ci-multi-runner":
        ensure => "running",
    }
}
