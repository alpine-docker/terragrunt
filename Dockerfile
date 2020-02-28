# variables "TERRAGRUNT_VERSION" and "TERRAFORM_VERSION" must be passed as docker environment variables during the image build
# docker build --no-cache --build-arg TERRAFORM_VERSION=0.12.21 --build-arg TERRAGRUNT_VERSION=v0.22.4 -t alpine/terragrunt:0.12.21 .
ARG TERRAGRUNT_VERSION
ARG TERRAFORM_VERSION

FROM hashicorp/terraform:${TERRAFORM_VERSION} as terraform


FROM terraform as builder

ARG TERRAGRUNT_VERSION

ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt

RUN chmod +x /usr/local/bin/terragrunt


FROM terraform

RUN apk add --update --no-cache bash git openssh

COPY --from=builder /usr/local/bin/terragrunt /usr/local/bin/terragrunt

WORKDIR /apps

ENTRYPOINT []
