define gitlab_ci_multi_runner::runner ( 
    ########################################################
    # Runner Options                                       #
    # Used By all Executors.                               #
    ########################################################

    #URL of the Gitlab Server.
    $gitlab_ci_url      = undef,
    #Array of tags
    $tags               = undef,
    #CI Token
    $token              = undef,
    #Executor - Shell, parallels, ssh, docker etc
    $executor           = undef,

    ########################################################
    # Docker Options                                       #
    # Used by the Docker and Docker SSH executors.         #
    ########################################################

    # The Docker Image (eg. ruby:2.1)
    $docker_image       = undef,
    # Run Docker containers in privileged mode
    $docker_privileged  = undef,
    #mysql version (X.Y) or latest
    $docker_mysql       = undef,
    # postgres version (X.Y) or latest
    $docker_postgres    = undef,
    # redis version (X.Y) or latest
    $docker_redis       = undef,
    # mongo version (X.Y) or latest
    $docker_mongo       = undef,

    ########################################################
    # Parallels Options                                    #
    # Used by the "Parallels" executor.                    #
    ########################################################

    # The Parallels VM (eg. my-vm)
    $parallels_vm       = undef,

    ########################################################
    # SSH Options                                          #
    # Used by the SSH, Docker SSH, and Parllels Executors. #
    ########################################################

    # The SSH Server Address
    $ssh_host           = undef,
    # The SSH Server Port
    $ssh_port           = undef,
    # The SSH User
    $ssh_user           = undef,
    # The SSH Password
    $ssh_password       = undef,
    #REQUIRE CI_MULTI_RUNNER
    $require            = [ Class['gitlab_ci_multi_runner'] ],
) {

    $description = $name

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

    # Register a new runner - this is where the magic happens.
    exec {"Register-${name}":
        command  => "gitlab-ci-multi-runner register ${opts} ",
        user     => $user,
        provider => shell,
        onlyif   => "! grep ${description} ${home_path}/config.toml", #Only if the config.toml file doesn't already contain an entry.
        cwd      => "${home_path}"
    }
}
