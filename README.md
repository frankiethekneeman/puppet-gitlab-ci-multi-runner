# Puppet Gitlab CI Multi Runner
---
A module for the installation and use of the [Gitlab CI MultiRunner](https://github.com/ayufan/gitlab-ci-multi-runner) written in Go.

Installation takes place via the instructions found 
[here](https://github.com/ayufan/gitlab-ci-multi-runner/blob/master/docs/install/linux-repository.md) - Repo is added, 
User created and managed, and the Runners are registered.

The YUM version is hard set to v4.2 because 5.0 does not run well on CentOS Systems.

##Usage

```puppet
class {'gitlab_ci_multi_runner': }

gitlab_ci_multi_runner::runner { "This is My Runner":
    gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
    tags          => ['tag', 'tag2','java', 'php'],
    token         => 'sometoken'
    executor      => 'shell',
}

gitlab_ci_multi_runner::runner { "This is My Second Runner":
    gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
    tags          => ['tag', 'tag2','npm', 'grunt'],
    token         => 'sometoken'
    executor      => 'ssh',
    ssh_host      => 'cirunners.examplecorp.com'
    ssh_port      => 22
    ssh_user      => 'mister-ci'
    ssh_password  => 'password123'
}
```

##Runner Options

All options are pulled from the Gitlab CI MultiRunner registration command - The name of the runner will be used to
Generate the description when registering the Runner.

###Standard Options
Used By all Executors.

####gitlab\_ci\_url
> The GitLab-CI Coordinator URL

####tags
This is a list of tags to apply to the runner - it takes an array, which will be joined into a comma separated list of tags.

####token
> The GitLab-CI Token for this Runner

####executor
> The Executor: shell, docker, docker-ssh, ssh?

The Runner is packages with a "Parallels" Executor as well.

### Docker Options
Used by the Docker and Docker SSH executors.

####docker\_image
> The Docker Image (eg. ruby:2.1)

####docker\_privileged
> Run Docker containers in privileged mode

Any truthy value will set this off.

####docker\_mysql
> If you want to enable mysql please enter version (X.Y) or enter latest

####docker\_postgres
> If you want to enable postgres please enter version (X.Y) or enter latest

####docker\_redis
> If you want to enable redis please enter version (X.Y) or enter latest

####docker\_mongo
> If you want to enable mongo please enter version (X.Y) or enter latest

###Parallels Options
Used by the "Parallels" executor.

####parallels\_vm
> The Parallels VM (eg. my-vm)

###SSH Options
Used by the SSH, Docker SSH, and Parllels Executors.

####ssh\_host
> The SSH Server Address (eg. my.server.com)

####ssh\_port
> The SSH Server Port (eg. 22)

####ssh\_user
> The SSH User (eg. root)

####ssh\_password
> The SSH Password (eg. docker.io)

## Contributing

Please maintain sensible spacing between logical blocks of code, and a 4 space indent - no tabs, thank you.

Other than that, please open pull requests for any features you can.
