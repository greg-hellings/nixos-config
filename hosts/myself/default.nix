{ config, pkgs, lib, ... }:

{
	imports = [	
		./hardware-configuration.nix
	];

	environment.systemPackages = with pkgs; [
		git
		(python3.withPackages (p: with p; [ pip virtualenv ]))
		tmux
		tree
		vim
		xonsh
	];
	services = {
		openssh.enable = true;
	};
	systemd.services = let
		def = id: {
			enable = true;
			ephemeral = false;
			extraEnvironment = {
				HTTP_PORT_MIN = builtins.toString (8000 + id);
				HTTP_PORT_MAX = builtins.toString (8000 + id);
			};
			extraLabels = [ "nixos" "isaiah" ];
			extraPackages = with pkgs; [
				config.virtualisation.virtualbox.host.package
				curl
				gawk
				packer
				pup
				(python3.withPackages (p: with p; [ pip virtualenv ]))
				qemu_full
				qemu_kvm
				xonsh
				xorriso
			];
			name = "isaiah-nix-${builtins.toString id}";
			nodeRuntimes = [ "node20" ];
			package = pkgs.github-runner;
			replace = true;
			runnerGroup = null;
			serviceOverrides = {
				Group = "vboxusers";
			};
			tokenFile = "/etc/github_token";
			user = "runner";
			url = "https://github.com/greg-hellings/vms";
			workDir = "/home/runner/${builtins.toString id}";
		};
		runner = (import ./runner.nix);
	in {
		gh-one = (runner { inherit config lib pkgs; svcName = "gh-one"; cfg = def 1; });
		gh-two = (runner { inherit config lib pkgs; svcName = "gh-two"; cfg = def 2; });
		gh-three = (runner { inherit config lib pkgs; svcName = "gh-three"; cfg = def 3; });
		gh-four = (runner { inherit config lib pkgs; svcName = "gh-four"; cfg = def 4; });
		gh-five = (runner { inherit config lib pkgs; svcName = "gh-five"; cfg = def 5; });
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
			} ];
		};
		nameservers = [
			"10.42.1.5"
		];
	};
	virtualisation = {
		libvirtd = {
			enable = false;
			onBoot = "ignore";
		};
		virtualbox.host = {
			enable = true;
			enableExtensionPack = true;
		};
	};
	users = {
		users = {
			runner = {
				extraGroups = [
					"kvm"
					"vboxusers"
				];
				group = "runner";
				isNormalUser = true;
			};
			greg = {
				extraGroups = [
					"kvm"
					"sudo"
					"vboxusers"
					"wheel"
				];
				isNormalUser = true;
			};
		};
		groups.runner = {};
	};
	system.stateVersion = lib.mkForce "24.05";
	boot = {
		extraModprobeConfig = "options kvm_amd nested=1 vboxdrv";
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
	};
	nixpkgs.config = {
		allowUnfree = true;
		permittedInsecurePackages = [
			"nodejs-16.20.2"
		];
	};
}
