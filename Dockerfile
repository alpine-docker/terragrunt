ARG TERRAFORM

FROM quay.io/terraform-docs/terraform-docs:latest as docs
FROM hashicorp/terraform:${TERRAFORM}

ARG TERRAGRUNT
ARG BOILERPLATE

RUN apk add --update --no-cache bash git openssh

COPY --from=docs /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs

# Determine the target architecture using uname -m
RUN case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "Unsupported architecture, exiting..."; exit 1; ;; \
    esac \
    && TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT}/terragrunt_linux_${ARCH}" \
    && wget -q "${TERRAGRUNT_URL}" -O /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

RUN case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "Unsupported architecture, exiting..."; exit 1; ;; \
    esac \
    && BOILERPLATE_URL="https://github.com/gruntwork-io/boilerplate/releases/download/v${BOILERPLATE}/boilerplate_linux_${ARCH}" \
    && wget -q "${BOILERPLATE_URL}" -O /usr/local/bin/boilerplate \
    && chmod +x /usr/local/bin/boilerplate

WORKDIR /apps

ENTRYPOINT []

