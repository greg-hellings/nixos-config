{ pkgs, ... }:

pkgs.writeShellScriptBin "hms" ''
set -eo pipefail
# Build different targets with GUI or not

arch="$(uname -m)"
if [ "$(uname -s)" == "Darwin" ]; then
	# On macOS
	src="$HOME/.config/nix/"
	target="''${arch}-darwin"
else
	# On Linux/WSL2 systems
	if [ -z "$DISPLAY" ]; then
		target="''${arch}-nogui"
	else
		target="''${arch}-gui"
	fi
	src=/etc/nixos
fi

# Build and switch
echo "Building $(uname -m)-$target"
dest=$(mktemp -d)
pushd "$dest" > /dev/null
nix build --impure "$src#homeConfigurations.$target.activationPackage"
./result/activate
popd > /dev/null
rm -r "$dest"
''
