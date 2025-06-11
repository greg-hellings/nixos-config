# vim: set ft=bash:

set -ex -o pipefail

# Build and switch
system="$(uname -s)"

# Determine where the Flake is
if [ "$system" == "Darwin" ]; then
    try_src="/etc/nix-darwin"
else
    try_src="/etc/nixos"
fi
if [ -d "$try_src" ]; then
    src="$try_src"
    target="$(hostname)"
else
    src="$HOME/.config/nix"
    target="$(whoami)"
fi

# Find the hostname
echo "Building user for ${target}"

# Build the system
dest=$(mktemp -d)
trap cleanup 1 2 3 6 15

function cleanup {
    echo "Cleaning up"
    rm -r "${dest}"
    exit
}

pushd "${dest}" > /dev/null
nom build "${src}#homeConfigurations.\"${target}\".activationPackage"
./result/activate
popd > /dev/null
