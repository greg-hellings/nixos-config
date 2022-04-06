{ config, pkgs, ... }:

{
  imports = [
    ./networking.nix
    ./dnsmasq.nix
	./home-assistant.nix
    ../profiles/rpi4.nix
	../profiles/home.nix
  ];
  networking.hostName = "2maccabees";
  networking.domain = "home.thehellings.com";
}
