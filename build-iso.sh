#!/usr/bin/env bash

beta="${1}"

nix build ".#nixosConfigurations.iso${beta}.config.system.build.isoImage"
