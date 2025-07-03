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
kubectl annotate nodes isaiah 'node.longhorn.io/default-disks-config=[
  { "path": "/var/lib/longhorn", "allowScheduling" : true }
]'
kubectl annotate nodes jeremiah 'node.longhorn.io/default-disks-config=[
  { "path": "/var/lib/longhorn", "allowScheduling" : true }
]'
kubectl annotate nodes zeke 'node.longhorn.io/default-disks-config=[
  { "path": "/var/lib/longhorn", "allowScheduling" : true }
]'

kubectl apply -k namespaces
kubectl apply -f helm/flux.yaml
sleep 5
kubectl apply -f helm/kyverno.yaml
sleep 15
kubectl apply -k helm
sleep 5
kubectl apply -k .
