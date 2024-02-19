{
	pkgs,
	coreutils,
	curl,
	gnutar,
	nix,
	...
}:
pkgs.writeShellScriptBin "inject-darwin" ''
set -ex
set -o pipefail

dir="$(${coreutils}/bin/mktemp -d)"
cd "''${dir}"

# Install nix-darwin
${nix}/bin/nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# Get my configuration
mkdir -p ~/.config/darwin
cd ~/.config/darwin
${curl}/bin/curl -O -L https://github.com/greg-hellings/nixos-config/archive/refs/heads/main.tar.gz
${gnutar}/bin/tar xvzf main.tar.gz --strip-components 1

# Build NixOS for this system
pushd "''${dir}"
${nix}/bin/nix build "~/.config/darwin#darwinConfigurations.$(hostname -s).system"
./result/sw/bin/darwin-rebuild switch --flake ~/.config/darwin
popd
rm -r "''${dir}"
''
