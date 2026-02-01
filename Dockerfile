# --- Build Stage ---
FROM alpine:3.23 AS builder

# Define the Terraform version
ARG TF_VERSION=1.14.4


RUN apk add --no-cache curl unzip && \
    curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip && \
    unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TF_VERSION}_linux_amd64.zip && \
    apk del curl unzip

# --- Test Stage ---
# This step runs during 'docker build'. If it fails, the build stops.
RUN terraform --version

FROM alpine:3.23
COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform

WORKDIR /workspace
ENTRYPOINT ["terraform"]