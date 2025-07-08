#!/usr/bin/env bash


# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

kubectl apply -k "$SCRIPT_DIR"

# https://www.dragonflydb.io/guides/redis-kubernetes
# Deploys into immich namespace, directly, in order to allow the password to be
# accessed by the immich installer
helm upgrade --install --create-namespace --namespace immich redis \
    oci://registry-1.docker.io/bitnamicharts/redis \
    -f "${SCRIPT_DIR}/values-redis.yaml" \
    --wait
# https://github.com/immich-app/immich-charts/tree/main
helm upgrade --install --create-namespace --namespace immich immich \
    oci://ghcr.io/immich-app/immich-charts/immich \
    -f "${SCRIPT_DIR}/values.yaml" \
    --wait
