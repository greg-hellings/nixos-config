{ pkgs, nixpkgs, lib, ... }:
{

	imports = [
		"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
	];

	networking.networkmanager.enable = lib.mkForce false;
	users.users.greg.initialPassword = "";
	services.getty.autologinUser = lib.mkForce "greg";
}
