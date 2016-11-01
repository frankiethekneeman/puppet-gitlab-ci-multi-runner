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
#      token         => 'sometoken'
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
#
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
    $require = [ Class['gitlab_ci_multi_runner'] ]
) {
    # GitLab allows runner names with problematic characters like quotes
    # Make sure they don't trip up the shell when executed
    $description = shellquote($name)

    # Here begins the arduous, manual process of taking each argument
    # and turning it into option strings.
    # TODO find a better way to read this.

    if $gitlab_ci_url {
        $gitlab_ci_url_opt = "--url=${gitlab_ci_url}"
    }

    if $description {
        $description_opt = $::gitlab_ci_multi_runner::version ? {
            /^0\.[0-4]\..*/ => "--description=${description}",
            default         => "--name=${description}",
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

    # I group like arguments together so my final opstring won't be so giant.
    $runner_opts = "${gitlab_ci_url_opt} ${description_opt} ${tags_opt} ${token_opt} ${env_opts}"

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
            --docker-volumes=<%= \"'#{volume}'\" -%>
            <% end -%>"
        )
    }

    $docker_opts = "${docker_image_opt} ${docker_privileged_opt} ${docker_mysql_opt} ${docker_postgres_opt} ${docker_redis_opt} ${docker_mongo_opt} ${docker_allowed_images_opt} ${docker_allowed_services_opt} ${docker_volumes_opt}"

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

    $opts = "${runner_opts} ${executor_opt} ${docker_opts} ${parallels_vm_opt} ${ssh_opts}"

    # Register a new runner - this is where the magic happens.
    # Only if the config.toml file doesn't already contain an entry.
    # --non-interactive means it won't ask us for things, it'll just fail out.
    exec { "Register-${name}":
        command  => "gitlab-ci-multi-runner register --non-interactive ${opts}",
        user     => $user,
        provider => shell,

        onlyif   => "! grep ${description} ${::gitlab_ci_multi_runner::toml_file}",
        cwd      => $home_path,
        require  => $require,
    }
}
