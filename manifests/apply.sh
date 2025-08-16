#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory
cd "$SCRIPT_DIR"

# First, label the nodes to control Longhorn rollout
for n in isaiah jeremiah zeke; do
    kubectl label nodes "${n}" "node.longhorn.io/create-default-disk=config"
done
# Now, configure longhorn settings for each node
kubectl annotate nodes --overwrite isaiah 'node.longhorn.io/default-disks-config=[
  { "path": "/var/lib/longhorn", "allowScheduling" : true, "tags": ["hdd", "large"]}
]'
kubectl annotate nodes --overwrite jeremiah 'node.longhorn.io/default-disks-config=[
  { "path": "/var/lib/longhorn", "allowScheduling" : true, "tags": ["hdd", "large"]}
]'
kubectl annotate nodes --overwrite zeke 'node.longhorn.io/default-disks-config=[
  { "path": "/var/lib/longhorn", "allowScheduling" : trues, "tags": ["ssd", "fast"]}
]'

kubectl apply -f helm/flux.yaml
sleep 5
kubectl apply -f helm/kyverno.yaml
sleep 15
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
kubectl apply -k .

./immich/apply.sh
