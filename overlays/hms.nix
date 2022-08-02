{ pkgs, ... }:

pkgs.writeShellScriptBin "hms" ''
set -eo pipefail
# Build different targets with GUI or not
if [ -z "$DISPLAY" ]; then
	target="nogui"
else
	target="gui"
fi

# Build and switch
echo "Building $(uname -m)-$target"
dest=$(mktemp -d)
pushd "$dest" > /dev/null
nix build --impure /etc/nixos#homeConfigurations.$(uname -m)-$target.activationPackage
./result/activate
popd > /dev/null
rm -r "$dest"
''
