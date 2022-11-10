# vim: set ft=bash:
set -eo pipefail
# Build different targets with GUI or not

arch="$(uname -m)"
if [ "$(uname -s)" == "Darwin" ]; then
	# On macOS
	src="${HOME}/.config/nix/"
	target="${arch}-darwin"
else
	# On Linux/WSL2 systems
	if [ -z "${DISPLAY}" ]; then
		target="${arch}-nogui"
	else
		target="${arch}-gui"
	fi
	src=/etc/nixos
fi

# Build and switch
echo "Building ${target}"
dest=$(mktemp -d)
pushd "${dest}" > /dev/null
nix build --impure "${src}#homeConfigurations.${target}.activationPackage"
./result/activate
popd > /dev/null
rm -r "${dest}"

if [ "$(uname -s)" == "Darwin" ]; then
	cd ~/.nix-profile/Applications
	for app in *.app; do
		echo "Updating permissions on '${app}'"
		chmod -R u+w "${HOME}/Applications/${app}" || true
		echo "Copying new version to Applications"
		cp -r "${app}" "${HOME}/Applications" 2>&1 > /dev/null || true
		if [ "$?" != "0" ]; then
			echo "An error occurred, proceeding anyway"
		fi
	done
fi
