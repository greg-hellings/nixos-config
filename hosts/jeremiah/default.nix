# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
		];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "jeremiah"; # Define your hostname.
	greg = {
	home = true;
		tailscale.enable = true;
	};
	environment.systemPackages = with pkgs; [
		btrfs-progs
	];
	
	fileSystems = {
		"/nix" = {
			fsType = "btrfs";
			options = [ "subvol=nix" ];
			device = "/dev/nvme0n1p1";
		};
		"/var" = {
			fsType = "btrfs";
			options = [ "subvol=var" ];
			device = "/dev/nvme0n1p1";
		};
	};
}
