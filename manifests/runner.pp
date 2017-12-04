# == Define: gitlab_ci_multi_runner::runner
#
# Define for creating a gitlab-ci runner.
#
# gitlab_ci_multi_runner can/should be included to install
# gitlab-ci-multi-runner if needed.
#
# === Parameters
#
# [*user*]
#   The user to manage or run as
#   You may want to use root.
#   Default: gitlab_ci_multi_runner.
#
# [*gitlab_ci_url*]
#   URL of the Gitlab Server.
#   Default: undef.
#
# [*tags*]
#   Array of tags.
#   Default: undef.
#
# [*token*]
#   CI Token.
#   Default: undef.
#
# [*env*]
#   Custom environment variables injected to build environment.
#   Default: undef.
#
# [*run_untagged*]
#   Whether this runner runs builds without a tag.
#   Default: undef.
#
# [*executor*]
#   Executor - Shell, parallels, ssh, docker etc.
#   Default: undef.
#
# [*docker_image*]
#   The Docker Image (eg. ruby:2.1).
#   Default: undef.
#
# [*docker_privileged*]
#   Run Docker containers in privileged mode.
#   Default: undef.
#
# [*docker_mysql*]
#   MySQL version (X.Y) or latest.
#   Default: undef.
#
# [*docker_postgres*]
#   Postgres version (X.Y) or latest.
#   Default: undef.
#
# [*docker_redis*]
#   Redis version (X.Y) or latest.
#   Default: undef.
#
# [*docker_mongo*]
#   Mongo version (X.Y) or latest.
#   Default: undef.
#
# [*docker_allowed_images*]
#   Array of wildcard list of images that can be specified in .gitlab-ci.yml
#   Default: undef.
#
# [*docker_allowed_services*]
#   Array of wildcard list of services that can be specified in .gitlab-ci.yml
#   Default: undef.
#
# [*docker_volumes*]
#   Array of volumes that will be mounted to every docker container used for builds.
#   Default: undef.
#
# [*parallels_vm*]
#   The Parallels VM (eg. my-vm).
#   Default: undef.
#
# [*ssh_host*]
#   The SSH Server Address.
#   Default: undef.
#
# [*ssh_port*]
#   The SSH Server Port.
#   Default: undef.
#
# [*ssh_user*]
#   The SSH User.
#   Default: undef.
#
# [*ssh_password*]
#   The SSH Password.
#   Default: undef.
#
# [*require*]
#   Array of requirements for the runner registration resource.
#   Default: [ Class['gitlab_ci_multi_runner'] ].
#
# [*cache_type*]
#   Select caching method: s3, to use S3 buckets.
#   Default: undef.
#
# [*cache_s3_server_address*]
#   A host:port to the used S3_compatible server.
#   Default: undef.
#
# [*cache_s3_access_key*]
#   S3 Access Key
#   Default: undef.
#
# [*cache_s3_secret_key*]
#   S3 Secret Key.
#   Default: undef.
#
# [*cache_s3_bucket_name*]
#   Name of the bucket where cache will be stored.
#   Default: undef.
#
# [*cache_s3_bucket_location*]
#   Name of S3 region.
#   Default: undef.
#
# [*cache_s3_insecure*]
#   Use insecure mode (without https).
#   Default: undef.
#
# [*cache_s3_cache_path*]
#   Name of the path to prepend to the cache URL.
#   Default: undef.
#
# [*cache_cache_shared*]
#   Enable cache sharing between runners.
#   Default: undef.
#
# [*machine_idle_nodes*]
#   Maximum idle machines.
#   Default: undef.
#
# [*machine_idle_time*]
#   Minimum time after node can be destroyed.
#   Default: undef.
#
# [*machine_max_builds*]
#   Maximum number of builds processed by machine.
#   Default: undef.
#
# [*machine_machine_driver*]
#   The driver to use when creating machine.
#   Default: undef.
#
# [*machine_machine_name*]
#   The template for machine name (needs to include %s).
#   Default: undef.
#
# [*machine_machine_options*]
#   Additional machine creation options.
#   Default: undef.
#
# === Examples
#
#  gitlab_ci_multi_runner::runner { "This is My Runner":
#      gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
#      tags          => ['tag', 'tag2','java', 'php'],
#      token         => 'sometoken'
#      executor      => 'shell',
#  }
#
#  gitlab_ci_multi_runner::runner { "This is My Second Runner":
#      gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
#      tags          => ['tag', 'tag2','npm', 'grunt'],
#      token         => 'sometoken',
#      executor      => 'ssh',
#      ssh_host      => 'cirunners.examplecorp.com'
#      ssh_port      => 22
#      ssh_user      => 'mister-ci'
#      ssh_password  => 'password123'
#  }
#
#  gitlab_ci_multi_runner::runner { "This is My Third Runner using Docker":
#      gitlab_ci_url           => 'http://ci.gitlab.examplecorp.com'
#      tags                    => ['tag', 'tag2','npm', 'grunt'],
#      token                   => 'sometoken'
#      executor                => 'docker',
#      docker_image            => 'ruby:2.1',
#      docker_postgres         => '9.5',
#      docker_allowed_services => ['elasticsearch', 'memcached', 'haproxy'],
#      docker_allowed_images   => ['ruby', 'wordpress'],
#      docker_volumes          => ['/var/run/docker.sock:/var/run/docker.sock', '/src/webapp:/opt/webapp']
#  }
#;

define gitlab_ci_multi_runner::runner (
    $user = 'gitlab_ci_multi_runner',

    ########################################################
    # Runner Options                                       #
    # Used By all Executors.                               #
    ########################################################

    $gitlab_ci_url = undef,
    $tags = undef,
    $token = undef,
    $env = undef,
    $executor = undef,
    $run_untagged = undef,
    $locked = undef,
    $cache_dir = undef,
    $concurrent = undef,
    $metrics_server = undef,

    ########################################################
    # Docker Options                                       #
    # Used by the Docker and Docker SSH executors.         #
    ########################################################

    $docker_image = undef,
    $docker_privileged = undef,
    $docker_mysql = undef,
    $docker_postgres = undef,
    $docker_redis = undef,
    $docker_mongo = undef,
    $docker_allowed_images = undef,
    $docker_allowed_services = undef,
    $docker_volumes = undef,
    $docker_host = undef,
    $docker_cert_path = undef,
    $docker_tlsverify = undef,

    ########################################################
    # Cache Options                                        #
    # Used by Docker to send cache to S3                   #
    ########################################################

    $cache_type = undef,
    $cache_s3_server_address = undef,
    $cache_s3_access_key = undef,
    $cache_s3_secret_key = undef,
    $cache_s3_bucket_name = undef,
    $cache_s3_bucket_location = undef,
    $cache_s3_insecure = undef,
    $cache_s3_cache_path = undef,
    $cache_cache_shared = undef,

    ########################################################
    # Machine Options                                      #
    # Used by the Docker-Machine executor                  #
    ########################################################

    $machine_idle_nodes = undef,
    $machine_idle_time = undef,
    $machine_max_builds = undef,
    $machine_machine_driver = undef,
    $machine_machine_name = undef,
    $machine_machine_options = undef,

    ########################################################
    # Parallels Options                                    #
    # Used by the "Parallels" executor.                    #
    ########################################################

    $parallels_vm = undef,

    ########################################################
    # SSH Options                                          #
    # Used by the SSH, Docker SSH, and Parllels Executors. #
    ########################################################

    $ssh_host = undef,
    $ssh_port = undef,
    $ssh_user = undef,
    $ssh_password = undef,


    $kubernetes_host = undef,
    $kubernetes_cert_file = undef,
    $kubernetes_key_file = undef,
    $kubernetes_ca_file = undef,
    $kubernetes_image = undef,
    $kubernetes_namespace = undef,
    $kubernetes_priviledged = undef,
    $kubernetes_cpus = undef,
    $kubernetes_memory = undef,
    $kubernetes_service_cpus = undef,
    $kubernetes_service_memory = undef,

    $require = [ Class['gitlab_ci_multi_runner'] ]
) {
    # GitLab allows runner names with problematic characters like quotes
    # Make sure they don't trip up the shell when executed
    $node_description = shellquote($::fqdn)

    # Here begins the arduous, manual process of taking each argument
    # and turning it into option strings.
    # TODO find a better way to read this.

    if $gitlab_ci_url {
        $gitlab_ci_url_opt = "--url=${gitlab_ci_url}"
    }

    if $node_description {
        $node_description_opt = $::gitlab_ci_multi_runner::version ? {
            /^0\.[0-4]\..*/ => "--node_description=${node_description}",
            default         => "--name=${node_description}",
        }
    }

    if $tags {
        $tagstr = join($tags,',')
        $tags_opt = "--tag-list=${tagstr}"
    }

    if $token {
        $token_opt = "--registration-token=${token}"
    }

    if $env {
        $envarry = prefix(any2array($env),'--env=')
        $env_opts = join($envarry,' ')
    }

    if $run_untagged != undef {
        if $run_untagged {
            $run_untagged_opt = '--run-untagged=true'
        }
        else {
            $run_untagged_opt = '--run-untagged=false'
        }
    }

    if $locked!=undef {
        $locked_opt = "--locked=${locked}"
    }

    if $cache_dir{
        $cache_dir_opt = "--cache-dir=${cache_dir}"
    }

    # I group like arguments together so my final opstring won't be so giant.
    $runner_opts = "${gitlab_ci_url_opt} ${node_description_opt} ${tags_opt} ${locked_opt} ${token_opt} ${env_opts} ${run_untagged_opt} ${cache_dir_opt} "

    if $executor {
        $executor_opt = "--executor=${executor}"
    }

    if $docker_image {
        $docker_image_opt = "--docker-image=${docker_image}"
    }

    if $docker_privileged {
        $docker_privileged_opt = '--docker-privileged'
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

    if $docker_allowed_images {
        $docker_allowed_images_opt = inline_template(
          "<% @docker_allowed_images.each do |image| -%>
            --docker-allowed-images=<%= \"'#{image}'\" -%>
            <% end -%>"
        )
    }

    if $docker_allowed_services {
        $docker_allowed_services_opt = inline_template(
          "<% @docker_allowed_services.each do |service| -%>
            --docker-allowed-services=<%= \"'#{service}'\" -%>
            <% end -%>"
        )
    }

    if $docker_volumes {
        $docker_volumes_opt = inline_template(
          "<% @docker_volumes.each do |volume| -%>
            --docker-volumes <%= \"#{volume}\"-%>
            <% end -%>"
        )
    }

    if $docker_host {
        $docker_host_opt = "--docker-host=${docker_host}"
    }

    if $docker_cert_path {
        $docker_cert_path_opt = "--docker-cert-path=${docker_cert_path}"
    }

    if $docker_tlsverify {
        $docker_tlsverify_opt = "docker-tlsverify=${docker_tlsverify}"
    }

    $docker_opts = "${docker_host_opt} ${docker_cert_path_opt} ${docker_tlsverify_opt} ${docker_image_opt} ${docker_privileged_opt} ${docker_mysql_opt} ${docker_postgres_opt} ${docker_redis_opt} ${docker_mongo_opt} ${docker_allowed_images_opt} ${docker_allowed_services_opt} ${docker_volumes_opt}"

    if $cache_type {
      $cache_type_opt = "--cache-type=${cache_type}"
    }

    if $cache_s3_server_address {
      $cache_s3_server_address_opt = "--cache-s3-server-address=${cache_s3_server_address}"
    }

    if $cache_s3_access_key {
      $cache_s3_access_key_opt = "--cache-s3-access-key=${cache_s3_access_key}"
    }

    if $cache_s3_secret_key {
      $cache_s3_secret_key_opt = "--cache-s3-secret-key=${cache_s3_secret_key}"
    }

    if $cache_s3_bucket_name {
      $cache_s3_bucket_name_opt = "--cache-s3-bucket-name=${cache_s3_bucket_name}"
    }

    if $cache_s3_bucket_location {
      $cache_s3_bucket_location_opt = "--cache-s3-bucket-location=${cache_s3_bucket_location}"
    }

    if $cache_s3_insecure {
      $cache_s3_insecure_opt = "--cache-s3-insecure=${cache_s3_insecure}"
    }

    if $cache_s3_cache_path {
      $cache_s3_cache_path_opt = "--cache-s3-cache-path=${cache_s3_cache_path}"
    }

    if $cache_cache_shared {
      $cache_cache_shared_opt = "--cache-cache-shared=${cache_cache_shared}"
    }

    $cache_opts="${cache_type_opt} ${cache_s3_server_address_opt} ${cache_s3_access_key_opt} ${cache_s3_secret_key_opt} ${cache_s3_bucket_name_opt} ${cache_s3_bucket_location_opt} ${cache_s3_insecure_opt} ${cache_s3_cache_path_opt} ${cache_cache_shared_opt}"

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

    if $machine_idle_nodes {
        $machine_idle_nodes_opt = "--machine-idle-nodes=${machine_idle_nodes}"
    }

    if $machine_idle_time {
        $machine_idle_time_opt = "--machine-idle-time=${machine_idle_time}"
    }

    if $machine_max_builds {
        $machine_max_builds_opt = "--machine-max-builds=${machine_max_builds}"
    }

    if $machine_machine_driver {
        $machine_machine_driver_opt = "--machine-machine-driver=${machine_machine_driver}"
    }

    if $machine_machine_name {
        $machine_machine_name_opt = "--machine-machine-name=${machine_machine_name}"
    }

    if $machine_machine_options {
        $machine_machine_options_opt = inline_template(
          "<% @machine_machine_options.each do |options| -%>
            --machine-machine-options=<%= \"'#{options}'\" -%>
            <% end -%>"
        )
    }

    $machine_opts="${machine_idle_nodes_opt} ${machine_idle_time_opt} ${machine_max_builds_opt} ${machine_machine_driver_opt} ${machine_machine_name_opt} ${machine_machine_options_opt}"

    if $kubernetes_host {
        $kubernetes_host_opt="--kubernetes-host=${kubernetes_host}"
    }

    if $kubernetes_cert_file {
        $kubernetes_cert_file_opt="--kubernetes_cert_file=${kubernetes_cert_file}"
    }

    if $kubernetes_key_file {
        $kubernetes_key_file_opt="--kubernetes-key-file=${kubernetes_key_file}"
    }

    if $kubernetes_ca_file {
        $kubernetes_ca_file_opt="--kubernetes-ca-file=${kubernetes_ca_file}"
    }

    if $kubernetes_image {
        $kubernetes_image_opt="--kubernetes_image=${kubernetes_image}"
    }

    if $kubernetes_namespace {
        $kubernetes_namespace_opt="--kubernetes-namespace=${kubernetes_namespace}"
    }

    if $kubernetes_priviledged {
        $kubernetes_priviledged_opt="--kubernetes-priviledged=${kubernetes_priviledged}"
    }

    if $kubernetes_cpus {
        $kubernetes_cpus_opt="--kubernetes-cpus=${kubernetes_cpus}"
    }

    if $kubernetes_memory {
        $kubernetes_memory_opt="--kubernetes-memory=${kubernetes_memory}"
    }

    if $kubernetes_service_cpus {
        $kubernetes_service_cpus_opt="--kubernetes-service-cpus=${kubernetes_service_cpus}"
    }

    if $kubernetes_service_memory {
        $kubernetes_service_memory_opt="--kubernetes-service-memory=${kubernetes_service_memory}"
    }

    $kubernetes_opts="${kubernetes_host_opt} ${kubernetes_cert_file_opt} ${kubernetes_key_file_opt} ${kubernetes_ca_file_opt} ${kubernetes_image_opt} ${kubernetes_namespace_opt} ${kubernetes_priviledged_opt} ${kubernetes_cpus_opt} ${kubernetes_memory_opt} ${kubernetes_service_cpus_opt} ${kubernetes_service_memory_opt}"

    $opts = "${runner_opts} ${executor_opt} ${docker_opts} ${cache_opts} ${parallels_vm_opt} ${ssh_opts} ${machine_opts} ${kubernetes_opts}"
    notify{"Will run gitlab-ci-multi-runner register --non-interactive ${opts}": }

    # Register a new runner - this is where the magic happens.
    # Only if the config.toml file doesn't already contain an entry.
    # --non-interactive means it won't ask us for things, it'll just fail out.
    exec { "Register-${node_description}-${gitlab_ci_url}":
        command  => "gitlab-ci-multi-runner register --non-interactive ${opts}",
        user     => $user,
        provider => shell,
        onlyif   => "! grep ${gitlab_ci_url} ${::gitlab_ci_multi_runner::toml_file}",
      cwd        => $::gitlab_ci_multi_runner::home_path,
      require    => $require,
    }

    if $concurrent {
      file_line { "concurrent-${gitlab_ci_url}":
        path    => $::gitlab_ci_multi_runner::toml_file,
        line    => "concurrent = ${concurrent} ",
        match   => '^concurrent *',
        require => Exec["Register-${node_description}-${gitlab_ci_url}"]
      }
    }

    if $metrics_server {
      file_line { "change_metrics_server-${gitlab_ci_url}":
        path    => $::gitlab_ci_multi_runner::toml_file,
        after   => 'check_interval *',
        line    => "metrics_server = \"${metrics_server}\"",
        match   => '^metrics_server *',
        require => Exec["Register-${node_description}-${gitlab_ci_url}"],
      }
    }
  }