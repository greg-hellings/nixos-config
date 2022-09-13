{ pkgs, agenix, ... }:

let
	myPackages = pypackages: with pypackages; [
		pkgs.datadog-api-client
		pkgs.xonsh-direnv
		datadog
		dateutil
		ipython
		pyyaml
		responses
		ruamel-yaml
		typing-extensions
		virtualenv
	];

	myPython = pkgs.python3.withPackages myPackages;
in {
	# Base packages that need to be in all my hosts
	environment.systemPackages = with pkgs; [
		agenix.defaultPackage."${system}"
		android-file-transfer
		bitwarden-cli
		diffutils
		git
		gnupatch
		findutils
		hms # My own home manager switcher
		home-manager
		htop
		myPython
		pwgen
		tmux
		transcrypt
		unzip
		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
		yamllint  # Used in vim
	];
}
