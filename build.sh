#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

image="alpine/terragrunt"
terraform_repo="hashicorp/terraform"
terragrunt_repo="gruntwork-io/terragrunt"

if [[ ${CI} == 'true' ]]; then
  CURL="curl -sL -H \"Authorization: token ${API_TOKEN}\""
else
  CURL="curl -sL"
fi

latest_terraform=$(${CURL} https://api.github.com/repos/${terraform_repo}/releases/latest |jq -r .tag_name|sed 's/v//')

latest_terragrunt=$(${CURL} https://api.github.com/repos/${terragrunt_repo}/releases/latest |jq -r .tag_name)

# Define tag for Alpine Terragrunt releases
latest_alpine_terragrunt=${latest_terragrunt}-tf${latest_terraform}

sum=0
echo "Latest Terraform release is: ${latest_terraform}"
echo "Latest Terragrunt release is: ${latest_terragrunt}"
echo "Latest Alpine Terragrunt tag is: ${latest_alpine_terragrunt}"

tags=`curl -s https://hub.docker.com/v2/repositories/${image}/tags/ |jq -r .results[].name`

for tag in ${tags}
do
  if [ ${tag} == ${latest_alpine_terragrunt} ];then
    sum=$((sum+1))
  fi
done

if [[ ( $sum -ne 1 ) || ( ${REBUILD} == "true" ) ]];then
  sed "s/TERRAFORM_VERSION/${latest_terraform}/" Dockerfile.template > Dockerfile
  docker build --build-arg TERRAGRUNT_VERSION=${latest_terragrunt} --build-arg TERRAFORM_VERSION=${latest_terraform} --no-cache -t ${image}:${latest_alpine_terragrunt} .
  docker tag ${image}:${latest_alpine_terragrunt} ${image}:latest

  if [[ "$TRAVIS_BRANCH" == "master" && "$TRAVIS_PULL_REQUEST" == false ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${latest_alpine_terragrunt}
    docker push ${image}:latest
  fi

fi
