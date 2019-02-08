# Bundler: manage a Ruby application's gems
Auto-trigger docker build for [bundler](https://bundler.io/) when new ruby release is announced

### Repo:

https://github.com/alpine-docker/bundler

### Daily build logs:

https://travis-ci.org/alpine-docker/bundler

### Docker iamge tags:

https://hub.docker.com/r/alpine/bundle/tags/

# Usage:

    # must mount the local folder to /apps in container.
    $ docker run -ti -v $(pwd):/apps alpine/bundle:2.4.2 bash
    $ bundle install
    $ bundle exec rake 

    # run bundle container as command
    alias bundle="docker run -ti --rm -v $(pwd):/apps alpine/bundle:2.4.2 bundle "
    bundle --help 

# The Processes to build this image

* Enable Travis CI cronjob on this repo to run build daily on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with latest version as tag and push to hub.docker.com
