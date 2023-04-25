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
  local tag="${1}"
  local terragrunt="${2}"
  local image_name="${3}"
  
  # Create a new buildx builder instance
  docker buildx create --name mybuilder --use
  
  # Build the Docker image for multiple platforms
  sed "s/VERSION/${latest_terraform}/" Dockerfile.template > Dockerfile

  # docker buildx build \
  #   --platform "linux/386,linux/amd64,linux/arm/v6,linux/arm64" \
  #   --build-arg TERRAGRUNT="${terragrunt}" \
  #   --no-cache \
  #   --tag "${image_name}:${tag}" \
  #   --tag "${image_name}:latest" \
  #   .
 
   docker buildx build \
    --platform "linux/386,linux/amd64,linux/arm64" \
    --build-arg TERRAGRUNT="${terragrunt}" \
    --no-cache \
    --tag "${image_name}:${tag}" \
    --tag "${image_name}:latest" \
    .

  # Push the Docker image for all platforms
  echo docker buildx push "${image_name}:${tag}"
  echo docker buildx push "${image_name}:latest"
  
  # Remove the buildx builder instance
  docker buildx rm mybuilder
}

latest_terraform=$(get_latest_release "${terraform_repo}")
latest_terragrunt=$(get_latest_release "${terragrunt_repo}")
echo "Latest terraform release is: ${latest_terraform}"
echo "Latest terragrunt release is: ${latest_terragrunt}"

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
  REBUILD="true"
fi

REBUILD="true"

if [[ ( "${sum}" -ne 1 ) || ( "${REBUILD}" == "true" ) ]]; then
  build_docker_image "${latest_terraform}" "${latest_terragrunt}" "${image}"
fi

