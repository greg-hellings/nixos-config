#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

kubectl apply -k namespaces
kustomize build postgres --enable-helm | kubectl apply -f - --server-side --force-conflicts
kubectl apply -k .
