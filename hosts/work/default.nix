{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		vim
		wget
	];

	services.nix-daemon.enable = true;
}
