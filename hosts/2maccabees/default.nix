{ config, pkgs, ... }:

{
	imports = [
		./networking.nix
		./dnsmasq.nix
		./home-assistant.nix
		./vhosts.nix
		../../profiles/rpi4.nix
		../../profiles/home.nix
	];
	networking.hostName = "2maccabees";
}
