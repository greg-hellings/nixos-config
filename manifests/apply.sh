#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

kubectl apply -k namespaces
kustomize build external-secrets --enable-helm | kubectl apply -f -
echo -e "\nPausing for a moment to allow the External Secrets stuff to get going\n"
sleep 5
kustomize build postgres --enable-helm | kubectl apply -f - --server-side --force-conflicts
echo -e "\nPausing for a moment to allow Postgres stuff to get going\n"
sleep 5
kubectl apply -k .
