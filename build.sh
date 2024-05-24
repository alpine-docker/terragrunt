#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret environment variables in CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

# set -ex

image="alpine/terragrunt"
terraform_repo="hashicorp/terraform"
terragrunt_repo="gruntwork-io/terragrunt"
boilerplate_repo="gruntwork-io/boilerplate"
opentofu_repo="opentofu/opentofu"

if [[ "${CI}" == "true" ]]; then
  CURL="curl -sL -H \"Authorization: token ${API_TOKEN}\""
else
  CURL="curl -sL"
fi

function get_latest_release() {
  ${CURL} -s "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name | ltrimstr("v")'
}

function get_published_date() {
  ${CURL} -s "https://api.github.com/repos/$1/releases/latest" | jq -r '.published_at'
}

function get_image_published_date() {
  ${CURL} -s "https://hub.docker.com/v2/repositories/$1/tags/" | jq -r '.results[] | select(.name == "latest") | .last_updated'
}

function get_image_tags() {
  ${CURL} -s "https://hub.docker.com/v2/repositories/$1/tags/" | jq -r '.results[].name'
}

function build_docker_image() {
  local terraform="${1}"
  local terragrunt="${2}"
  local boilerplate="${3}"
  local opentofu="${4}"
  local image_name="${5}"
  
  # Create a new buildx builder instance
  docker buildx create --name mybuilder --use
  
  # Build the Docker image for multiple platforms
  if [[ "$CIRCLE_BRANCH" == "master" ]]; then 
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker buildx build \
     --platform "linux/386,linux/amd64,linux/arm64" \
     --build-arg TERRAFORM="${terraform}" \
     --build-arg TERRAGRUNT="${terragrunt}" \
     --build-arg BOILERPLATE="${boilerplate}" \
     --build-arg OPENTOFU="${opentofu}" \
     --no-cache \
     --push \
     --tag "${image_name}:${terraform}" \
     --tag "${image_name}:${terraform%.*}" \
     --tag "${image_name}:${terraform%%.*}" \
     --tag "${image_name}:latest" \
     .
  fi
  
  # Remove the buildx builder instance
  docker buildx rm mybuilder
}

latest_terraform=$(get_latest_release "${terraform_repo}")
latest_terragrunt=$(get_latest_release "${terragrunt_repo}")
latest_boilerplate=$(get_latest_release "${boilerplate_repo}")
latest_opentofu=$(get_latest_release "${opentofu_repo}")
echo "Latest terraform release is: ${latest_terraform}"
echo "Latest terragrunt release is: ${latest_terragrunt}"
echo "Latest boilerplate release is: ${latest_boilerplate}"
echo "Latest opentofu release is: ${latest_opentofu}"

tags=$(get_image_tags "${image}")

sum=0
for tag in ${tags}; do
  if [ "${tag}" == "${latest_terraform}" ]; then
    sum=$((sum + 1))
  fi
done

terragrunt_published_date=$(get_published_date "${terragrunt_repo}")
image_published_date=$(get_image_published_date "${image}")

# If Terragrunt has a newer published date, then we have to force a build
if [ "$(date -d "${terragrunt_published_date}" +%s)" -gt "$(date -d "${image_published_date}" +%s)" ]; then
  BUILD="true"
fi

if [[ ( "${sum}" -ne 1 ) || ( "${REBUILD}" == "true" ) || ( "${BUILD}" == "true" ) ]]; then
  build_docker_image "${latest_terraform}" "${latest_terragrunt}" "${latest_boilerplate}" "${latest_opentofu}" "${image}"
fi
