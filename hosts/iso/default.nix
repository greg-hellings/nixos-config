{ pkgs, lib, modulesPath, ... }:
{

	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
		"${modulesPath}/installer/cd-dvd/channel.nix"
	];

	networking.networkmanager.enable = lib.mkForce false;
	users.users.greg.initialPassword = "";
	#services.getty.autologinUser = lib.mkForce "greg";
}
