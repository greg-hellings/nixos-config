# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, overlays, ... }:
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


	# Bootloader
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot/";
			};
		};
		extraModprobeConfig = "vboxdrv";
	};
	users.users.greg.extraGroups = [ "vboxusers" ];

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
		gitlab-runner = {
			enable = true;
			settings.concurrent = 5;
			services = {
				shell = {
					executor = "shell";
					limit = 5;
					registrationConfigFile = config.age.secrets.runner-reg.path;
					environmentVariables = {
						EFI_DIR = "${pkgs.OVMF.fd}/FV/";
					};
				};
			};
		};
	};

	#####################################################################################
	#################### Virtualbox Runner ##############################################
	#####################################################################################
	age.secrets.runner-reg.file = ../../secrets/gitlab/myself-vbox-runner-reg.age;
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
		# Moved here from myself/Isaiah, so technically unnecessary now
		conflicts = [
			"container@gitlab-runner-qemu.service"
		];
		wants = [
			"network-online.target"
			"systemd-resolved.service"
		];
		path = with pkgs; [
			curl
			gawk
			git
			p7zip
			packer
			pup
			gregpy
			shellcheck
			unzip
			xonsh
			xorriso
			vagrant
			wget
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

	networking.firewall.allowedTCPPorts = [ 18083 ];  # Should be interface for vboxweb
}
