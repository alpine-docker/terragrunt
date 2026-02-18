#!/usr/bin/env bash

docker run -ti --rm -v $(pwd)/test/test-terragrunt:/apps -w /apps cbcvaughan/terragrunt bash -c "terragrunt --version > result && terragrunt init && terragrunt apply -auto-approve && echo $? >> result"
echo $?
echo "==== test terragrunt result ===="
cat test/test-terragrunt/result

docker run -ti --rm -v $(pwd)/test/test-terraform:/apps -w /apps cbcvaughan/terragrunt bash -c "terraform --version > result && terragrunt init && terragrunt apply -auto-approve && echo $? >> result"
echo $?
echo "==== test terraform result ===="
cat test/test-terraform/result

docker run -ti --rm -v $(pwd)/test/test-opentofu:/apps -w /apps cbcvaughan/terragrunt bash -c "tofu --version > result && terragrunt init && terragrunt apply -auto-approve && echo $? >> result"
echo $?
echo "==== test opentofu result ===="
cat test/test-opentofu/result
