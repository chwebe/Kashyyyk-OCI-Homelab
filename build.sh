#!/bin/bash

# --- Variables ---
TF_VERSION="1.14.4"
ALPINE_VERSION="3.23"
IMAGE_NAME="oci-terraform"

# Create a full tag string
FULL_TAG="${IMAGE_NAME}:${TF_VERSION}-alpine${ALPINE_VERSION}"

echo "🚀 Starting build for ${FULL_TAG}..."

# --- Build Command ---
# --build-arg passes the variables into the Dockerfile
# -t applies the version-specific tag
docker build \
  --build-arg TF_VERSION=${TF_VERSION} \
  --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
  -t ${FULL_TAG} \
  -t ${IMAGE_NAME}:latest .

# --- Check Result ---
if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  echo "Image tagged as: ${FULL_TAG}"
  echo "Image tagged as: ${IMAGE_NAME}:latest"
else
  echo "❌ Build failed. Please check the logs above."
  exit 1
fi