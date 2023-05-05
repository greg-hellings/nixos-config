#!/usr/bin/env bash

hostname="${1}"
if [ -n "${hostname}"]; then
	echo "You must provide a hostname";
	exit 1;
fi

curl -L -o "${HOME}/nixos-config.tar.gz" https://github.com/greg-hellings/nixos-config/archive/refs/heads/main.tar.gz
tar xaf "${HOME}/nixos-config.tar.gz" -C "${HOME}"
sudo mv /etc/nixos /etc/nixos.bk
sudo mv "${HOME}/nixos-config-main/" /etc/nixos
mkdir -p "/etc/nixos/hosts/${hostname}"

# Prepares everything for the flake usage
cp /etc/nixos.bk/configuration.nix "/etc/nixos/hosts/${hostname}/default.nix"
cp /etc/nixos.bk/hardware-configuration.nix "/etc/nixos/hosts/${hostname}/hardware-configuration.nix"

# Prepares it for injecting the use case into the flake usage
cp /etc/nixos.bk/hardware-configuration.nix /etc/nixos

echo "Now you should be able to just run 'nixos-rebuild switch' to enable the flake functionality"
echo "After that and adding the entry to the flake, run 'nixos-rebuild boot --flake '.#${hostname}' and reboot"

