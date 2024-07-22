# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
			./ceph.nix
			./hardware-configuration.nix
			./minio.nix
		];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking = {
		hostName = "jeremiah"; # Define your hostname.
		useDHCP = false;
		defaultGateway = {
			address = " 10.42.1.1";
			interface = "enp68s0";
		};
		vlans = {
			san = {
				id = 616;
				interface = "enp67s0";
			};
		};
		interfaces = {
			enp68s0 = {
				ipv4.addresses = [ {
					address = "10.42.1.8";
					prefixLength = 16;
				} {
					address = "10.42.100.1";
					prefixLength = 16;
				} ];
			};
			san = {
				ipv4.addresses = [ {
					address = "10.201.1.2";
					prefixLength = 24;
				} ];
			};
		};
		nameservers = [
			"10.42.1.5"
		];
	};
	greg = {
	home = true;
		tailscale.enable = true;
	};
	environment.systemPackages = with pkgs; [
		btrfs-progs
		curl
		gawk
		git
		p7zip
		packer
		pup
		gregpy
		shellcheck
		unzip
		xorriso
		vagrant
		wget
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

	#####################################################################################
	#################### Virtualbox Runner ##############################################
	#####################################################################################
	services = {
		gitlab-runner = {
			enable = true;
			settings.concurrent = 7;
			services = {
				shell = {
					executor = "shell";
					limit = 5;
					registrationConfigFile = config.age.secrets.runner-reg.path;
					environmentVariables = {
						EFI_DIR = "${pkgs.OVMF.fd}/FV/";
						STORAGE_URL = "http://localhost:9000";
					};
				};
			};
		};
	};
	age.secrets.runner-reg.file = ../../secrets/gitlab/jeremiah-runner-reg.age;
	virtualisation.virtualbox.host = {
		enable = true;
		enableExtensionPack = true;
		enableHardening = false;
		headless = true;
	};

	systemd.services."gitlab-runner" = {
		after = [
			"network.target"
			"network-online.target"
			"systemd-resolved.service"
		];
		wants = [
			"network-online.target"
			"systemd-resolved.service"
		];
		preStart = builtins.concatStringsSep "\n" [
			"${pkgs.kmod}/bin/modprobe vboxdrv"
			"${pkgs.kmod}/bin/modprobe vboxnetadp"
			"${pkgs.kmod}/bin/modprobe vboxnetflt"
		];
		postStop = "${pkgs.kmod}/bin/rmmod vboxnetadp vboxnetflt vboxdrv";
		serviceConfig = {
			DevicePolicy = lib.mkForce "auto";
			User = "root";
			DynamicUser = lib.mkForce false;
		};
	};
}
