#!/usr/bin/env bash

# Use first argument as the image name. If not provided, run tests locally.
IMAGE_NAME=$1

run_test() {
  local test_dir=$1
  local tool=$2
  local cmd=$3
  
  echo "==== Testing $tool in $test_dir ===="
  
  if [ -n "$IMAGE_NAME" ]; then
    docker run --rm -v "$(pwd)/test/$test_dir":/apps -w /apps "$IMAGE_NAME" bash -c "$cmd"
  else
    (
      cd "test/$test_dir" || exit 1
      bash -c "$cmd"
    )
  fi
  
  local exit_code=$?
  echo "Exit code: $exit_code"
  echo "==== Result for $tool ===="
  cat "test/$test_dir/result"
  return $exit_code
}

# Define commands
TERRAGRUNT_CMD="terragrunt --version > result && terragrunt init && terragrunt apply -auto-approve && echo \$? >> result"
TERRAFORM_CMD="terraform --version > result && terragrunt init && terragrunt apply -auto-approve && echo \$? >> result"
OPENTOFU_CMD="tofu --version > result && terragrunt init && terragrunt apply -auto-approve && echo \$? >> result"

# Run tests
run_test "test-terragrunt" "terragrunt" "$TERRAGRUNT_CMD" || exit 1
run_test "test-terraform" "terraform" "$TERRAFORM_CMD" || exit 1
run_test "test-opentofu" "opentofu" "$OPENTOFU_CMD" || exit 1
