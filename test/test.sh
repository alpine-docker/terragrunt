#!/usr/bin/env bash

docker run -ti --rm -v $(pwd)/test/test-terragrunt:/apps -w /apps alpine/terragrunt bash -c "terragrunt --version > result && terragrunt init && terragrunt apply -auto-approve && echo $? >> result"
echo $?
echo "==== test terragrunt result ===="
cat test/test-terragrunt/result

docker run -ti --rm -v $(pwd)/test/test-opentofu:/apps -w /apps alpine/terragrunt bash -c "tofu --version > result && terragrunt init && terragrunt apply -auto-approve && echo $? >> result"
echo $?
echo "==== test opentofu result ===="
cat test/test-opentofu/result
