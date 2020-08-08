# enhanced tool to manage terraform deployment with terragrunt

Auto-trigger docker build for [terragrunt](https://github.com/gruntwork-io/terragrunt) when new terraform or terragrunt version is released.

[![DockerHub Badge](http://dockeri.co/image/alpine/terragrunt)](https://hub.docker.com/r/alpine/terragrunt/)

### Tools included in this container

* [terraform](https://terraform.io) - latest terraform version at time of build
* [terragrunt](https://github.com/gruntwork-io/terragrunt) -latest terragrunt version at time of build

### Repo:

https://github.com/alpine-docker/terragrunt

### Daily build logs:

https://travis-ci.org/alpine-docker/terragrunt

### Docker image tags:

The tag will be a combination of the terragrunt and terraform versions. The version for terragrunt will be listed first, followed by a -tf and the version of terraform included.  This enables updated releases when either terraform or terragrunt release new updates. 

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

Enable Travis CI cronjob on this repo to run build daily on master branch

The build.sh will:
* Check the latest version of Terraform via GitHub REST API
* Check the latest version of Terragrunt via GitHub REST API
* Generate the expected tag for the Alpine Terragrunt version
* Check the existing Alpine Terragrunt tags via dockerhub REST API
* If the expected tag does not exist in dockerhub, build the image with the expected tag and latest and push to [hub.docker.com](https://hub.docker.com/r/alpine/terragrunt/tags/)
