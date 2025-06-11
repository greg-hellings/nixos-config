#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

kubectl apply -k namespaces
kubectl apply -f helm/flux.yaml
sleep 5
kubectl apply -k helm
sleep 5
kubectl apply -k .
