# --- Build Stage ---
FROM alpine:3.23 AS builder

# Define the Terraform version
ARG TF_VERSION=1.14.4


RUN apk add --no-cache curl unzip && \
    curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip && \
    unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TF_VERSION}_linux_amd64.zip && \
    apk del curl unzip



# --- Final Stage ---
FROM alpine:3.23

RUN apk add --no-cache oci-cli

COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform

# Verification Test
RUN terraform --version && oci --version

ENV TF_PLUGIN_CACHE_DIR=/plugin-cache




