#!/usr/bin/env bash

set -ex
set -o pipefail

dir="$(mktemp -d)"
cd "${dir}"

# Install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# Get my configuration
mkdir -p ~/.config/darwin
cd ~/.config/darwin
curl -O -L https://github.com/greg-hellings/nixos-config/archive/refs/heads/main.tar.gz
tar xvzf main.tar.gz --strip-components 1

# Build NixOS for this system
cd "${dir}"
nix build "~/.config/darwin#darwinConfigurations.$(hostname -s).system"
./result/sw/bin/darwin-rebuild switch --flake ~/.config/darwin
