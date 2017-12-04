[![Build Status](https://travis-ci.org/frankiethekneeman/puppet-gitlab-ci-multi-runner.svg?branch=master)](https://travis-ci.org/frankiethekneeman/puppet-gitlab-ci-multi-runner)
# Help

This module has seen some use, and noone is more surprised than me.
I clearly don't have the bandwidth to maintain it properly anymore.
If you're interested in helping, please send me an email: fjvanw at thetadelt.com.
I will figure out how to deal with the credentials needed, here and on PuppetForge, at the time.

# Puppet Gitlab CI Multi Runner
---
A module for the installation and use of the 
[Gitlab CI MultiRunner](https://github.com/ayufan/gitlab-ci-multi-runner) written in Go.

Installation takes place via the instructions found 
[here](https://github.com/ayufan/gitlab-ci-multi-runner/blob/master/docs/install/linux-repository.md)
- Repo is added, User created and managed, and the Runners are registered.

The version of the gitlab-ci-multi-runner package is restricted to `v0.4.2` for RHEL5 and RHEL6 
derivatives due to restrictions identified on CentOS systems. RHEL7 and Debian derivatives are set to
use the most current release
 available.

## Usage

```puppet
class {'gitlab_ci_multi_runner': 
    nice => '15'
}

gitlab_ci_multi_runner::runner { "This is My Runner":
    gitlab_ci_url => 'http://ci.gitlab.examplecorp.com',
    tags          => ['tag', 'tag2','java', 'php'],
    token         => 'sometoken',
    executor      => 'shell',
}

gitlab_ci_multi_runner::runner { "This is My Second Runner":
    gitlab_ci_url => 'http://ci.gitlab.examplecorp.com',
    tags          => ['tag', 'tag2','npm', 'grunt'],
    token         => 'sometoken',
    executor      => 'ssh',
    ssh_host      => 'cirunners.examplecorp.com',
    ssh_port      => 22,
    ssh_user      => 'mister-ci',
    ssh_password  => 'password123'
}

gitlab_ci_multi_runner::runner { "This is My Third Runner using Docker":
    gitlab_ci_url           => 'http://ci.gitlab.examplecorp.com',
    tags                    => ['tag', 'tag2','docker', 'container'],
    token                   => 'sometoken',
    executor                => 'docker',
    docker_image            => 'ruby:2.1',
    docker_postgres         => '9.5',
    docker_allowed_services => ['elasticsearch', 'memcached', 'haproxy'],
    docker_allowed_images   => ['ruby', 'wordpress'],
    docker_volumes          => ['/var/run/docker.sock:/var/run/docker.sock', '/src/webapp:/opt/webapp']
}
```

## Installation Options

#### nice

Control the niceness of the actual process running the CI Jobs.  Valid values are from -20 to 19.
Leading '+' is optional.

#### version

Set the version of the gitlab-ci-multi-runner package. This can be to a specfic version number,
`present` (if you don't want Puppet to update it for you) or when undefined it defaults to `latest`.

As mentioned above, the version of the package will always be set to `v0.4.2` for RHEL5 and RHEL 6
derivatives.

## Runner Options

All options are pulled from the Gitlab CI MultiRunner registration command - The name of the runner
will be used to Generate the description when registering the Runner.

### Standard Options
Used By all Executors.

#### gitlab\_ci\_url
> The GitLab-CI Coordinator URL

#### tags
This is a list of tags to apply to the runner - it takes an array, which will be joined into a comma
separated list of tags.

#### token
> The GitLab-CI Token for this Runner

#### executor
> The Executor: shell, docker, docker-ssh, ssh?

The Runner is packages with a "Parallels" Executor as well.

#### run\_untagged
> Run builds without tag: true, false?

If you want this runner to execute builds without a tag given in .gitlab-ci.yml.
When undefined Gitlab defaults to true if no list of tags for this runner is
specified otherwise false.

### Docker Options
Used by the Docker and Docker SSH executors.

#### docker\_image
> The Docker Image (eg. ruby:2.1)

#### docker\_privileged
> Run Docker containers in privileged mode

Any truthy value will set this off.

#### docker\_mysql
> If you want to enable mysql please enter version (X.Y) or enter latest

#### docker\_postgres
> If you want to enable postgres please enter version (X.Y) or enter latest

#### docker\_redis
> If you want to enable redis please enter version (X.Y) or enter latest

#### docker\_mongo
> If you want to enable mongo please enter version (X.Y) or enter latest

#### docker\_volumes
> Specify a list of volumes that are being mounted to every docker container spawned by a docker
executor. For details see the
[official documentation about docker volumes](https://docs.docker.com/engine/userguide/containers/dockervolumes/).

### Parallels Options
Used by the "Parallels" executor.

#### parallels\_vm
> The Parallels VM (eg. my-vm)

### SSH Options
Used by the SSH, Docker SSH, and Parllels Executors.

#### ssh\_host
> The SSH Server Address (eg. my.server.com)

#### ssh\_port
> The SSH Server Port (eg. 22)

#### ssh\_user
> The SSH User (eg. root)

#### ssh\_password
> The SSH Password (eg. docker.io)

### Cache Options

#### cache\_type
>   Select caching method: s3, to use S3 buckets.

#### cache\_s3\_server\_address
>   A host:port to the used S3_compatible server.

#### cache\_s3\_access\_key
>   S3 Access Key

#### cache\_s3\_secret\_key
>   S3 Secret Key.

#### cache\_s3\_bucket\_name
>   Name of the bucket where cache will be stored.

#### cache\_s3\_bucket\_location*]
>   Name of S3 region.

#### cache\_s3\_insecure
>   Use insecure mode (without https).

#### cache\_s3\_cache\_path
>   Name of the path to prepend to the cache URL.

#### cache\_cache\_shared
>   Enable cache sharing between runners.

### Machine Options

#### machine\_idle\_nodes
>   Maximum idle machines.

#### machine\_idle\_time
>   Minimum time after node can be destroyed.

#### machine\_max\_builds
>   Maximum number of builds processed by machine.

#### machine\_machine\_driver
>   The driver to use when creating machine.

#### machine\_machine\_name
>   The template for machine name (needs to include %s).

#### machine\_machine\_options
>   Additional machine creation options.

## Contributing

Please maintain sensible spacing between logical blocks of code, and a 4 space indent - no tabs,
thank you.  Where line breaks are concerned - readability is the key here.  Since we're no longer
using [punch cards](http://programmers.stackexchange.com/questions/148677/why-is-80-characters-the-standard-limit-for-code-width)
to run our code, there's no need for our lines to fit into a specific line length 100% of the time.
That being said, this repository likes to wrap between 80 and 100 characters when possible, to
facilitate a broad range of coding display styles.  If you use 
[puppet-lint](http://puppet-lint.com/), I suggest you also use the flag to disable the 
[80 character line limit](http://puppet-lint.com/checks/80chars/).

Please open pull requests for any features you can, and make sure to update the README for your
features.
