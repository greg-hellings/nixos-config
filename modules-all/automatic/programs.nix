{ pkgs, ... }:

{
	# Base packages that need to be in all my hosts
	environment.systemPackages = with pkgs; [
		agenix
		android-file-transfer
		bitwarden-cli
		diffutils
		git
		gnupatch
		gregpy
		findutils
		hms # My own home manager switcher
		home-manager
		htop
		nano
		pwgen
		transcrypt
		unzip
		wget
	];
}
