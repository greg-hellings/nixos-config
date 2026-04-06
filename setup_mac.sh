#!/usr/bin/env bash

host="$(hostname -s)"

# Install XCode tools
echo "Installing XCode Tools"
xcode-select --install

# Install Homebrew
echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> ~/.zprofile
echo >> 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile

# Install Nix
echo "Installing Nix"
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

sudo mkdir /etc/nix-darwin
sudo chown -R $USER /etc/nix-darwin

# Install my configurations
cd /etc/nix-darwin
curl -O -L https://github.com/greg-hellings/nixos-config/archive/refs/heads/main.tar.gz
tar xvzf main.tar.gz --strip-components 1
mkdir -p "/etc/nix-darwin/darwin/hosts/${host}"
mkdir -p "/etc/nix-darwin/home/hosts/${host}"
/nix/var/nix/profiles/system/sw/bin/nix --extra-experimental-features "nix-command flakes" run greg-hellings/nixos-config#inject-darwin
