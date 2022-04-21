{ pkgs, agenix, ... }:

{
	# Base packages that need to be in all my hosts
	environment.systemPackages = with pkgs; [
		agenix.defaultPackage."${system}"
		diffutils
		git
		gnupatch
		findutils
		home-manager
		htop
		python3
		pwgen
		tmux
		transcrypt
		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
		xonsh
		yamllint  # Used in vim
	];
}
