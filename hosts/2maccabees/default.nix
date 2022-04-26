{ config, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
		./dnsmasq.nix
		./home-assistant.nix
		./networking.nix
		./vhosts.nix
	];
	networking.hostName = "2maccabees";
	greg.rpi4.enable = true;
}
