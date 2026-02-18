# Enhanced tool to manage Terraform and OpenTofu deployment with Terragrunt

Auto-trigger docker build for [terragrunt](https://github.com/gruntwork-io/terragrunt) when new terraform or opentofu versions are released.

[![DockerHub Badge](http://dockeri.co/image/cbcvaughan/terragrunt)](https://hub.docker.com/r/cbcvaughan/terragrunt/)

### Notes

* Never use tag `latest` in prod environment.
* Multi-Arch supported (linux/amd64, linux/arm64)
* For examples, below tags are supported now:
  - cbcvaughan/terragrunt:latest (based on latest terraform)
  - cbcvaughan/terragrunt:1.8.4 (terraform version)
  - cbcvaughan/terragrunt:tf1.8.4 (terraform version)
  - cbcvaughan/terragrunt:otf1.7.1 (opentofu version)

### Tools included in this container

* [terraform](https://terraform.io) - specific terraform version based on tag
* [opentofu](https://opentofu.org/) - specific opentofu version based on tag
* [terragrunt](https://github.com/gruntwork-io/terragrunt) - The latest terragrunt version when running the build.
* [boilerplate](https://github.com/gruntwork-io/boilerplate) - The latest boilerplate version when running the build.
* [terraform-docs](https://github.com/terraform-docs/terraform-docs) - The latest terraform-docs version when running the build.

### Repo:

https://github.com/cbcvaughan/terragrunt

### Daily build logs:

https://github.com/cbcvaughan/terragrunt/actions

### Docker image tags:

https://hub.docker.com/r/cbcvaughan/terragrunt/tags/

### Multiple platforms supported

* linux/arm64
* linux/amd64

# Why we need it

This is mostly used during Continuous Integration and Continuous Delivery (CI/CD), or as a component of an automated build and deployment process.

# Usage:

    # (1) must mount the local folder to /apps in container.
    # (2) must mount the aws credentials and ssh config folder in container.
    $ docker run -ti --rm -v $HOME/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh -v `pwd`:/apps cbcvaughan/terragrunt:latest bash
    #
    # common terraform steps
    $ terraform init
    $ terraform fmt
    $ terraform validate
    $ terraform plan
    $ terraform apply
    
    # common opentofu steps
    $ tofu init
    $ tofu fmt
    $ tofu validate
    $ tofu plan
    $ tofu apply
    
    # common terragrunt steps
    # cd to terragrunt configuration directory, if required.
    # Terraform and OpenTofu Version Compatibility Table
    # https://terragrunt.gruntwork.io/docs/getting-started/supported-versions/
    $ terragrunt hclfmt
    $ terragrunt run-all plan
    $ terragrunt run-all apply

# The Processes to build this image

* Enable CI cronjob on this repo to run build weekly on master branch
* Check if there are new versions announced via Terraform and OpenTofu Github REST APIs
* Match the existing docker image tags via Hub.docker.io REST API
* If not matched, build the image with latest `terraform version` or `opentofu version` as tag and push to hub.docker.com
* Always install latest version of terragrunt