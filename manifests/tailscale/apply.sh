#!/usr/bin/env bash

helm repo add tailscale https://pkgs.tailscale.com/helmcharts

helm repo update tailscale

helm upgrade \
    --install \
    tailscale-operator \
    tailscale/tailscale-operator \
    --namespace=tailscale \
    --create-namespace \
    --wait
