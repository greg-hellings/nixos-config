#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

kubectl delete -k .
kustomize build postgres --enable-helm | kubectl delete -f -
kubectl delete -k namespaces
