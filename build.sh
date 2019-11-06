#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

Usage() {
  echo "$0 [rebuild]"
}

image="alpine/terragrunt"
repo="hashicorp/terraform"

if [[ ${CI} == 'true' ]]; then
  CURL="curl -sL -H \"Authorization: token ${API_TOKEN}\""
else
  CURL="curl -sL"
fi

latest=$(${CURL} https://api.github.com/repos/${repo}/releases/latest |jq -r .tag_name|sed 's/v//')

terragrunt=$(${CURL} https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest |jq -r .tag_name)

sum=0
echo "Lastest release is: ${latest}"

tags=`curl -s https://hub.docker.com/v2/repositories/${image}/tags/ |jq -r .results[].name`

for tag in ${tags}
do
  if [ ${tag} == ${latest} ];then
    sum=$((sum+1))
  fi
done

if [[ ( $sum -ne 1 ) || ( $1 == "rebuild" ) ]];then
  sed "s/VERSION/${latest}/" Dockerfile.template > Dockerfile
  docker build --build-arg TERRAGRUNT=${terragrunt} --no-cache -t ${image}:${latest} .
  docker tag ${image}:${latest} ${image}:latest

  if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${latest}
    docker push ${image}:latest
  fi

fi
