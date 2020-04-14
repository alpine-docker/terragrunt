# enhanced tool to manage terraform deployment with terragrunt

Auto-trigger docker build for [terragrunt](https://github.com/gruntwork-io/terragrunt) when new terraform version is related.

[![DockerHub Badge](http://dockeri.co/image/alpine/terragrunt)](https://hub.docker.com/r/alpine/terragrunt/)

### Tools included in this container

* [terraform](https://terraform.io) - terraform version is this docker image's tag
* [terragrunt](https://github.com/gruntwork-io/terragrunt) - latest terragrunt version when run the build

### Repo:

https://github.com/alpine-docker/terragrunt

### Daily build logs:

https://travis-ci.org/alpine-docker/terragrunt

### Docker iamge tags:

https://hub.docker.com/r/alpine/terragrunt/tags/

# Usage:

    # (1) must mount the local folder to /apps in container.
    # (2) must mount the aws credentials and ssh config folder in container.
    $ docker run -ti --rm -v $HOME/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh -v `pwd`:/apps alpine/terragrunt:0.12.16 bash
    #
    # common terraform steps
    $ terraform init
    $ terraform fmt
    $ terraform validate
    $ terraform plan
    $ terraform apply
    #
    # common terragrunt steps
    # cd to terragrunt configuration directory, if required.
    $ terragrunt hclfmt
    $ terragrunt plan-all
    $ terragrunt apply-all

# The Processes to build this image

* Enable Travis CI cronjob on this repo to run build daily on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with latest `terraform version` as tag and push to hub.docker.com
* Always install latest version of terragrunt
