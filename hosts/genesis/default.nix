# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports = [
		# Include the results of the hardware scan.
		./hardware-configuration.nix
		./home-assistant.nix
		./networking.nix
	];
	
	greg.home = true;
	greg.gnome.enable = false;
	
	# Bootloader.
	boot.loader.grub = {
		enable = true;
		device = "/dev/vda";
		useOSProber = true;
	};

	#boot.loader = {
	#	systemd-boot.enable = true;
	#	efi = {
	#		canTouchEfiVariables = true;
	#		efiSysMountPoint = "/boot/efi";
	#	};
	#};
	
	networking.hostName = "genesis"; # Define your hostname.
	environment.systemPackages = with pkgs; [
		awscli2
	];
}
