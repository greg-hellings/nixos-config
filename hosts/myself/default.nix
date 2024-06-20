{ config, pkgs, lib, ... }:
{
	imports = [
		./ceph.nix
		./hardware-configuration.nix
		./git.nix
		./matrix.nix
		./minio.nix
	];

	environment.systemPackages = with pkgs; [
		git
		packer
		(python3.withPackages (p: with p; [ pip virtualenv ]))
		tmux
		tree
		vim
		xonsh
		xorriso
	];

	greg.tailscale.enable = true;

	services = {
		openssh.enable = true;
	};
	networking = {
		hostName = "myself";
		useDHCP = false;
		defaultGateway = {
			address = " 10.42.1.1";
			interface = "enp38s0";
		};
		interfaces.enp38s0 = {
			ipv4.addresses = [ {
				address = "10.42.1.6";
				prefixLength = 16;
			} {
				address = "10.42.100.1";
				prefixLength = 16;
			} ];
		};
		interfaces.enp39s0 = {
			ipv4.addresses = [ {
				address = "10.201.1.1";
				prefixLength = 24;
			} ];
		};
		nameservers = [
			"10.42.1.5"
		];
	};
	users = {
		users = {
			greg = {
				extraGroups = [
					"kvm"
					"sudo"
					"wheel"
				];
				isNormalUser = true;
			};
		};
	};
	system.stateVersion = lib.mkForce "24.05";
	boot = {
		extraModprobeConfig = "options kvm_amd nested=1";
		supportedFilesystems = [ "ntfs" ];
		loader = {
			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot";
			};
			systemd-boot = {
				enable = true;
				configurationLimit = 10;
			};
		};
		binfmt.emulatedSystems = [
			"aarch64-linux"
		];
	};
	nixpkgs.config = {
		allowUnfree = true;
		permittedInsecurePackages = [
			"nodejs-16.20.2"
		];
	};
}
