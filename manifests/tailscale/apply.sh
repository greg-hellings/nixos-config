#!/usr/bin/env bash

helm repo add tailscale https://pkgs.tailscale.com/helmcharts

helm repo update tailscale

helm upgrade \
    --install \
    tailscale-operator \
    tailscale/tailscale-operator \
    --namespace=tailscale \
    --create-namespace \
    --set-string oauth.clientId="$(bw get username 'ffa188a4-63b2-4926-99f0-b33b0021a4f4')" \
    --set-string oauth.clientSecret="$(bw get password 'ffa188a4-63b2-4926-99f0-b33b0021a4f4')" \
    --wait
