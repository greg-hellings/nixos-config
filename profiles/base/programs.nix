{ pkgs, agenix, ... }:

let
	myPackages = pypackages: with pypackages; [
		pkgs.xonsh-direnv
	];

	myPython = pkgs.python3.withPackages myPackages;
in {
	# Base packages that need to be in all my hosts
	environment.systemPackages = with pkgs; [
		agenix.defaultPackage."${system}"
		diffutils
		git
		gnupatch
		findutils
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
