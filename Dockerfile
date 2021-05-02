ARG TERRAFORM_VERSION
FROM hashicorp/terraform:${TERRAFORM_VERSION}

ARG TERRAGRUNT_VERSION

RUN apk add --update --no-cache bash git openssh jq

RUN wget -O /bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    chmod a+x /bin/terragrunt

WORKDIR /apps

ENTRYPOINT []
