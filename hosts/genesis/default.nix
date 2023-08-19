# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports = [
		# Include the results of the hardware scan.
		./dnsmasq.nix
		./hardware-configuration.nix
		./home-assistant.nix
		./networking.nix
		./vhosts.nix
	];
	
	greg.home = true;
	greg.gnome.enable = true;
	
	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot/efi";
		};
	};
	
	networking.hostName = "genesis"; # Define your hostname.
	
	# Enable sound with pipewire.
	sound.enable = true;
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa = {
			enable = true;
			support32Bit = true;
		};
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;
		
		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now)
		#media-session.enable = true;
	};
}
