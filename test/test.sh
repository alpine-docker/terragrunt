#!/usr/bin/env bash

docker run -ti --rm -v $(pwd)/test/test-terragrunt:/apps -w /apps alpine/terragrunt bash -c "terragrunt --version > result && terragrunt init && terragrunt apply -auto-approve && echo $? >> result"

echo "==== test result ===="
cat test/test-terragrunt/result
