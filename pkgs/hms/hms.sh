# vim: set ft=bash:
# Build different targets with GUI or not

# Build and switch
user="$(whoami)"
src="${HOME}/.config/nix"
echo "Building ${user}"
dest=$(mktemp -d)
pushd "${dest}" > /dev/null
nom build "${src}#homeConfigurations.\"${user}\".activationPackage"
./result/activate
popd > /dev/null
rm -r "${dest}"
