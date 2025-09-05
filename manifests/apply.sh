#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

kubectl apply -k helm
sleep 5
# https://cloudnative-pg.io
helm repo add cnpg https://cloudnative-pg.github.io/charts/
helm upgrade --install cnpg \
    --create-namespace --namespace cnpg-system \
    cnpg/cloudnative-pg \
    -f values/cnpg.yaml \
    --wait
sleep 5
./tailscale/apply.sh
kubectl apply -k .

./immich/apply.sh
