#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

image="alpine/terragrunt"
repo="hashicorp/terraform"

if [[ ${CI} == 'true' ]]; then
  CURL="curl -sL -H \"Authorization: token ${API_TOKEN}\""
else
  CURL="curl -sL"
fi

latest=$(${CURL} https://api.github.com/repos/${repo}/releases/latest |jq -r .tag_name|sed 's/v//')
eks="${latest}-eks"

terragrunt=$(${CURL} https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest |jq -r .tag_name)

sum=0
echo "Lastest terraform release is: ${latest}"

tags=`curl -s https://hub.docker.com/v2/repositories/${image}/tags/ |jq -r .results[].name`

for tag in ${tags}
do
  if [ ${tag} == ${eks} ];then
    sum=$((sum+1))
  fi
done

# get available Amazon EKS Kubernetes versions, only pick up the top version
# https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
KUBECTL=`curl -s https://raw.githubusercontent.com/awsdocs/amazon-eks-user-guide/master/doc_source/kubernetes-versions.md |egrep -A 10 "The following Kubernetes versions"|grep ^+ |awk '{gsub("\\\\", ""); print $NF}' |sort -Vr|head -1`

if [[ ( $sum -ne 1 ) || ( ${REBUILD} == "true" ) ]];then
  sed "s/VERSION/${latest}/" Dockerfile.template > Dockerfile
  docker build --build-arg TERRAGRUNT=${terragrunt} --build-arg KUBECTL=${KUBECTL} --no-cache -t ${image}:${eks} .

  # if [[ "$TRAVIS_BRANCH" == "eks" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${eks}
  # fi

fi
