# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
	wanInterface = "enp2s0";
	lanInterface = "enp1s0";
	lanIpAddress = "10.42.1.7";
in

{
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
		];


	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.efi.efiSysMountPoint = "/boot/";

	networking = {
		hostName = "hosea";
		interfaces = {
			"${wanInterface}".useDHCP = true;
			"${lanInterface}" = {
				useDHCP = false;
				ipv4.addresses = [{
					address = lanIpAddress;
					prefixLength = 24;
				}];
			};
		};
	};

	# Serves as the router, DHCP, and DNS for the site
	greg = {
		tailscale.enable = true;
		home = true;
	};
	services = {
		# Configure keymap
		xserver.xkb = {
			layout = "us";
			variant = "";
		};
	};
}
