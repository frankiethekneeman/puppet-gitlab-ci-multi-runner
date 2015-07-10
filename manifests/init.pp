class gitlab_ci_multi_runner (
    # SEE params.pp for parameter description.
    $gitlab_ci_url      = $gitlab_ci_multi_runner::params::gitlab_ci_url,
    $description        = $gitlab_ci_multi_runner::params::description,
    $tags               = $gitlab_ci_multi_runner::params::tags,
    $token              = $gitlab_ci_multi_runner::params::token,
    $executor           = $gitlab_ci_multi_runner::params::executor,
    $docker_image       = $gitlab_ci_multi_runner::params::docker_image,
    $docker_privileged  = $gitlab_ci_multi_runner::params::docker_privileged,
    $docker_mysql       = $gitlab_ci_multi_runner::params::docker_mysql,
    $docker_postgres    = $gitlab_ci_multi_runner::params::docker_postgres,
    $docker_redis       = $gitlab_ci_multi_runner::params::docker_redis,
    $docker_mongo       = $gitlab_ci_multi_runner::params::docker_mongo,
    $parallels_vm       = $gitlab_ci_multi_runner::params::parallels_vm,
    $ssh_host           = $gitlab_ci_multi_runner::params::ssh_host,
    $ssh_port           = $gitlab_ci_multi_runner::params::ssh_port,
    $ssh_user           = $gitlab_ci_multi_runner::params::ssh_user,
    $ssh_password       = $gitlab_ci_multi_runner::params::ssh_password,
    $package_manager    = $gitlab_ci_multi_runner::params::package_manager
) inherits gitlab_ci_multi_runner::params {

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
    $group = $user
    $home_path = "/home/${user}"

    # Here begins the arduous, manual process of taking each argument and turning it into option strings.
    # TODO find a better way to read this.

    if $gitlab_ci_url {
        $gitlab_ci_url_opt = "--url=${gitlab_ci_url}"
    }

    if $description {
        $description_opt = "--description=${description}"
    }

    if $tags {
        $tagstr    = join($tags,",")
        $tags_opt = "--tag-list=${tagstr}"
    }

    if $token {
        $token_opt = "--registration-token=${token}"
    }

    # I group like arguments together so my final opstring won't be so giant.
    $runner_opts = "${gitlab_ci_url_opt} ${description_opt} ${tags_opt} ${token_opt}"

    if $executor {
        $executor_opt = "--executor=${executor}"
    }

    if $docker_image {
        $docker_image_opt = "--docker-image=${docker_image}"
    }

    if $docker_privileged {
        $docker_privileged_opt = "--docker-privileged"
    }

    if $docker_mysql {
        $docker_mysql_opt = "--docker-mysql=${docker_mysql}"
    }

    if $docker_postgres {
        $docker_postgres_opt = "--docker-postgres=${docker_postgres}"
    }

    if $docker_redis {
        $docker_redis_opt = "--docker-redis=${docker_redis}"
    }

    if $docker_mongo {
        $docker_mongo_opt = "--docker-mongo=${docker_mongo}"
    }

    $docker_opts = "${docker_image_opt} ${docker_privileged_opt} ${docker_mysql_opt} ${docker_postgres_opt} ${docker_redis_opt} ${docker_mongo_opt}"

    if $parallels_vm {
        $parallels_vm_opt = "--parallels-vm=${parallels_vm}"
    }

    if $ssh_host {
        $ssh_host_opt = "--ssh-host=${ssh_host}"
    }

    if $ssh_port {
        $ssh_port_opt = "--ssh-port=${ssh_port}"
    }

    if $ssh_user {
        $ssh_user_opt = "--ssh-user=${ssh_user}"
    }

    if $ssh_password {
        $ssh_password_opt = "--ssh-password=${ssh_password}"
    }

    $ssh_opts = "${ssh_host_opt} ${ssh_port_opt} ${ssh_user_opt} ${ssh_password_opt}"

    # --non-interactive means it won't ask us for things, it'll just fail out.
    $opts = "--non-interactive ${runner_opts} ${executor_opt} ${docker_opts} ${parallels_vm_opt} ${ssh_opts}"

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
    # Register a new runner - this is where the magic happens.
    exec {"Register":
        command  => "gitlab-ci-multi-runner register ${opts} ",
        user     => $user,
        provider => shell,
        onlyif   => "[ ! -s '/home/${user}/config.toml' ]", #Only if the config.toml file is empty.
        cwd      => "/home/${user}"
    } ->
    # Ensure that the service is running at all times.
    service { "gitlab-ci-multi-runner":
        ensure => "running",
    }
}
