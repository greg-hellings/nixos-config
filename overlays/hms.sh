# vim: set ft=bash:
set -eo pipefail
# Build different targets with GUI or not

arch="$(uname -m)"
if [ "$(uname -s)" == "Darwin" ]; then
	# On macOS
	src="${HOME}/.config/darwin/"
	flavor="gui"
	if [ "${arch}" == "arm64" ]; then
		arch=aarch64
	fi
	arch="${arch}-darwin"
elif [ x"${WSL_DISTRO_NAME}" != "x" ]; then
	src=/etc/nixos
	flavor="cli"
	arch="${arch}-linux"
else
	# On Linux systems
	if [ -z "${DISPLAY}" ]; then
		flavor="cli"
	else
		flavor="gdm"
	fi
	src=/etc/nixos
	arch="${arch}-linux"
fi

# Build and switch
echo "Building ${flavor}.${arch}"
dest=$(mktemp -d)
pushd "${dest}" > /dev/null
nix build "${src}#homeConfigurations.${flavor}.${arch}.activationPackage"
./result/activate
popd > /dev/null
rm -r "${dest}"
