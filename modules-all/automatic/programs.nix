{ pkgs, ... }:

let
	myPackages = pypackages: with pypackages; [
		pkgs.my-py-addons.xonsh-direnv
		virtualenv
	];

	myPython = pkgs.python3.withPackages myPackages;
in {
	# Base packages that need to be in all my hosts
	environment.systemPackages = with pkgs; [
		agenix
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
		nano
		pwgen
		transcrypt
		unzip
		wget
	];
}
