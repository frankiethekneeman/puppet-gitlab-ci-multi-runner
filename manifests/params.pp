class gitlab_ci_multi_runner::params {
    ########################################################
    # Runner Options                                       #
    # Used By all Executors.                               #
    ########################################################

    #URL of the Gitlab Server.
    $gitlab_ci_url      = undef
    #Runner Description
    $description        = undef
    #Array of tags
    $tags               = undef
    #CI Token
    $token              = undef
    #Executor - Shell, parallels, ssh, docker etc
    $executor           = undef

    ########################################################
    # Docker Options                                       #
    # Used by the Docker and Docker SSH executors.         #
    ########################################################

    # The Docker Image (eg. ruby:2.1)
    $docker_image       = undef
    # Run Docker containers in privileged mode
    $docker_privileged  = undef
    #mysql version (X.Y) or latest
    $docker_mysql       = undef
    # postgres version (X.Y) or latest
    $docker_postgres    = undef
    # redis version (X.Y) or latest
    $docker_redis       = undef
    # mongo version (X.Y) or latest
    $docker_mongo       = undef

    ########################################################
    # Parallels Options                                    #
    # Used by the "Parallels" executor.                    #
    ########################################################

    # The Parallels VM (eg. my-vm)
    $parallels_vm       = undef

    ########################################################
    # SSH Options                                          #
    # Used by the SSH, Docker SSH, and Parllels Executors. #
    ########################################################

    # The SSH Server Address
    $ssh_host           = undef
    # The SSH Server Port
    $ssh_port           = undef
    # The SSH User
    $ssh_user           = undef
    # The SSH Password
    $ssh_password       = undef


    #The package manager version to add the repository for - RPM or APT. Currently, only RPM is supported because it's the only system 
    #I have to test for.

    $package_manager    = 'rpm'
    #TODO:  Get $package_manager from environment, not from parameter.
}
