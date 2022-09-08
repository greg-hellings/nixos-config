{ pkgs, ... }:

pkgs.writeShellScriptBin "hms" ''
set -eo pipefail
# Build different targets with GUI or not
if [ -z "$DISPLAY" ]; then
	target="nogui"
else
	target="gui"
fi

if [ "$(uname -s)" == "Darwin" ]; then
	src="$HOME/.config/nix/"
	target=gui
else
	src=/etc/nixos
fi

# Build and switch
echo "Building $(uname -m)-$target"
dest=$(mktemp -d)
pushd "$dest" > /dev/null
nix build --impure "$src#homeConfigurations.$(uname -m)-$target.activationPackage"
./result/activate
popd > /dev/null
rm -r "$dest"
''
