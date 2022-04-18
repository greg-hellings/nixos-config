{ config, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
		./dnsmasq.nix
		./home-assistant.nix
		./networking.nix
		./vhosts.nix
		../../profiles/rpi4.nix
		../../profiles/home.nix
	];
	networking.hostName = "2maccabees";
}
