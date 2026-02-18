ARG TERRAFORM
ARG OPENTOFU

FROM quay.io/terraform-docs/terraform-docs:latest as docs
FROM ghcr.io/opentofu/opentofu:${OPENTOFU} as tofu
FROM hashicorp/terraform:${TERRAFORM}

ARG TERRAGRUNT
ARG BOILERPLATE

RUN apk add --update --no-cache bash git openssh

COPY --from=docs /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# Determine the target architecture using uname -m
RUN case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

# install terragrunt
RUN . /envfile  && echo $ARCH && \  
    TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT}/terragrunt_linux_${ARCH}" && \
    wget -q "${TERRAGRUNT_URL}" -O /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# install boilerplate
RUN . /envfile  && echo $ARCH && \
    BOILERPLATE_URL="https://github.com/gruntwork-io/boilerplate/releases/download/v${BOILERPLATE}/boilerplate_linux_${ARCH}" && \
    wget -q "${BOILERPLATE_URL}" -O /usr/local/bin/boilerplate && \
    chmod +x /usr/local/bin/boilerplate

WORKDIR /apps

ENTRYPOINT []

