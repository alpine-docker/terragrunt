#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

image="gregorycuellar/terragrunt"
repo="hashicorp/terraform"

# Terragrunt supported-terraform versions
# https://terragrunt.gruntwork.io/docs/getting-started/supported-terraform-versions/
declare -A maximum_versions
maximum_versions[0.12]="0.24.4"
maximum_versions[0.11]="0.18.7"

if [[ ${CI} == 'true' ]]; then
  CURL="curl -sL -H \"Authorization: token ${API_TOKEN}\""
else
  CURL="curl -sL"
fi

all_terraform_tags=$(${CURL} https://api.github.com/repos/${repo}/releases | jq -r  '.[].tag_name' | sed 's/v//' | grep -Ev 'alpha|beta|rc')

latest_terragrunt_version=$(${CURL} https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest |jq -r .tag_name | sed 's/v//')

get_major_version () {
  local version=$1
  local version_s
  readarray -d . -t version_s <<< "${version}"
  version_s=("${version_s[@]:0:${#version_s[@]}-1}")
  local major_version=$(IFS=. ; echo "${version_s[*]}")
  echo "${major_version}"
}

all_needed_tags=()
for terraform_tag in ${all_terraform_tags}
do
  terraform_major_version=$(get_major_version "${terraform_tag}")
  
  # Check if terragrunt version is limited
  terragrunt_version=${maximum_versions[${terraform_major_version}]}
  if [ -z "${terragrunt_version}" ]
  then
    # If not limited, use the lastest version
    terragrunt_version=${latest_terragrunt_version}
  fi
  all_needed_tags+=("${terraform_tag}_${terragrunt_version}")
done


tags=`curl -s "https://hub.docker.com/v2/repositories/${image}/tags/?page_size=100" |jq -r ".results[].name"`

# Compare tags, and remove duplicate for major version
missing_tags=$(comm -23 <(IFS=$'\n'; echo "${all_needed_tags[*]}" | sort -r | sort -u -t. -k1,2) <(echo "${tags}" | sort | uniq))

for tag in ${missing_tags}
do
  readarray -d _ -t versions <<< "${tag}"
  terraform_version=${versions[0]//[$'\r\n']}
  terragrunt_version=${versions[1]//[$'\r\n']}
  echo "Building release for terraform(${terraform_version}) and terragrunt(${terragrunt_version})"

  docker build --build-arg TERRAFORM_VERSION=${terraform_version} --build-arg TERRAGRUNT_VERSION=${latest_terragrunt_version} --no-cache -t ${image}:${tag} .
  terraform_major_version=$(get_major_version "${terraform_version}")
  docker tag ${image}:${tag} ${image}:${terraform_major_version}
  docker tag ${image}:${tag} ${image}:latest

  if [[ "${TRAVIS_BRANCH}" == "master" && "${TRAVIS_PULL_REQUEST}" == false ]]; then
    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
    docker push ${image}:${tag}
    docker push ${image}:${terraform_major_version}
    docker push ${image}:latest
  fi
done
