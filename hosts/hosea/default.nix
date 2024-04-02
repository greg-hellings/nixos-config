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

	#####################################################################################
	#################### Virtualbox Runner ##############################################
	#####################################################################################
	systemd.services."container@gitlab-runner-vbox" = {
		# Moved here from myself/Isaiah, so technically unnecessary now
		conflicts = [
			"container@gitlab-runner-qemu.service"
		];
		serviceConfig = {
			DevicePolicy = lib.mkForce "auto";
			ExecStopPost = [ "${pkgs.kmod}/bin/rmmod vboxnetadp vboxnetflt vboxdrv" ];
			ExecStartPre = [
				"${pkgs.kmod}/bin/modprobe vboxdrv"
				"${pkgs.kmod}/bin/modprobe vboxnetadp"
				"${pkgs.kmod}/bin/modprobe vboxnetflt"
			];
		};
	};

	containers.gitlab-runner-vbox = {
		bindMounts."/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";  # For agenix secrets
		privateNetwork = true;
		bindMounts = {
			"/dev/vboxdrv" = {
				hostPath = "/dev/vboxdrv";
				isReadOnly = false;
			};
			"/dev/vboxdrvu" = {
				hostPath = "/dev/vboxdrvu";
				isReadOnly = false;
			};
			"/dev/vboxnetctl" = {
				hostPath = "/dev/vboxnetctl";
				isReadOnly = false;
			};
		};
		hostAddress = "192.168.202.1";
		localAddress = "192.168.202.2";
		config = ((import ../myself/container-runner.nix) {
			inherit inputs overlays;
			name = "vbox";
			extra = {
				systemd.services.gitlab-runner.serviceConfig = {
					User = "root";
					DynamicUser = lib.mkForce false;
				};
				virtualisation.virtualbox.host = {
					enable = true;
					enableExtensionPack = true;
					enableHardening = false;
					headless = true;
				};
				networking.firewall.allowedTCPPorts = [ 18083 ];  # Should be interface for vboxweb
			};
		});
	};
}
