# Puppet Gitlab CI Multi Runner
---
A module for the installation and use of the [Gitlab CI MultiRunner](https://github.com/ayufan/gitlab-ci-multi-runner) written in Go.

Installation takes place via the instructions found [here](https://github.com/ayufan/gitlab-ci-multi-runner/blob/master/docs/install/linux-repository.md) - Repo is added, User created and managed, and the Runner created.

This package is currently only capable of registering one runner per machine - Multi Registration is intended long term, but I don't know when I'll have time to work on it again.  I am however, very intersted and accepting of backwards compatible PRs.

##Options

All options are pulled from the Gitlab CI MultiRunner registration command.

###Runner Options
Used By all Executors.

####gitlab\_ci\_url
> The GitLab-CI Coordinator URL

####description
> The GitLab-CI Description for this Runner

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
