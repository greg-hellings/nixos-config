{ config, pkgs, lib, inputs, overlays, ... }:

let

	gitlabStateDir = "/var/lib/gitlab";

	container = input: (lib.attrsets.recursiveUpdate {
		bindMounts."/etc/ssh".hostPath = "/etc/ssh";  # For agenix secrets
		enableTun = true;
		privateNetwork = true;
	} input);
in  {
	networking = {
		firewall = {
			enable = true;
			allowedTCPPorts = [ 80 ];
		};
		nat = {
			enable = true;
			internalInterfaces = [ "ve-+" ];
			externalInterface  = "enp38s0";
		};
	};

	greg.proxies."git.thehellings.lan" = {
		target = "http://192.168.200.2";
		extraConfig = ''
		proxy_set_header X-Forwarded-Proto https;
		proxy_set_header X-Forwarded-Ssl on;
		'';
	};
	
	system.activationScripts.makeGitlabDir = lib.stringAfter [ "var" ] "mkdir -p ${gitlabStateDir} && touch ${gitlabStateDir}/touch";

	greg.containers.gitlab = {
		tailscale = true;
		subnet = "200";
		builder = (import ./container-git.nix);
	};

	systemd.services = {
		"gitlab-runner" = {
			after = [ "container@github.service" ];
			preStart = builtins.concatStringsSep "\n" [
				"${pkgs.kmod}/bin/modprobe kvm"
				"${pkgs.kmod}/bin/modprobe kvm_amd"
			];
			postStop = builtins.concatStringsSep "\n" [
				"${pkgs.kmod}/bin/rmmod -f kvm_amd kvm"
			];
			serviceConfig = {
				DevicePolicy = lib.mkForce "auto";
				DevicesAllow = [ "/dev/kvm" "/dev/mem" ];
				EnvironmentFile = config.age.secrets.docker-auth.path;
				PermissionsStartOnly = "true";
				PrivateDevices = false;
				ProtectKernelModules = false;
			};
		};
	};

	#####################################################################################
	#################### Container Podman Runner ########################################
	#####################################################################################
	containers.gitlab-runner-shell = container {
		autoStart = true;
		hostAddress = "192.168.203.1";
		localAddress = "192.168.203.2";
		config = ((import ./container-runner.nix) {
			inherit inputs overlays;
			name = "shell";
			extra.virtualisation.podman.enable = true;
		});
	};

	#####################################################################################
	#################### Local Podman/Docker Runner #####################################
	#####################################################################################
	age.secrets.runner-reg.file = ../../secrets/gitlab/myself-podman-runner-reg.age;
	age.secrets.docker-auth.file = ../../secrets/gitlab/docker-auth.age;
	age.secrets.runner-qemu.file = ../../secrets/gitlab/myself-qemu-runner-reg.age;
	services.gitlab-runner = {
		enable = true;
		settings = {
			concurrent = 5;
		};
		services = {
			default = {
				executor = "docker";
				registrationConfigFile = config.age.secrets.runner-reg.path;
				dockerImage = "gitlab.shire-zebra.ts.net:5000/greg/ci-images/fedora:latest";
				dockerAllowedImages = [
					"alpine:*"
					"debian:*"
					"docker:*"
					"fedora:*"
					"python:*"
					"ubuntu:*"

					"hashicorp/*:*"
					"koalaman/shellcheck:*"

					"registry.gitlab.com/gitlab-org/*"
					"registry.thehellings.com/*/*/*:*"
					"gitlab.shire-zebra.ts.net:5000/*/*/*:*"
				];
				dockerAllowedServices = [
					"docker:*"
					"registry.thehellings.com/*/*/*:*"
					"gitlab.shire-zebra.ts.net:5000/*/*/*:*"
				];
				dockerPrivileged = true;
				dockerVolumes = [
					"/certs/client"
					"/cache"
				];
			};
			qemu = {
				executor = "shell";
				limit = 5;
				registrationConfigFile = config.age.secrets.runner-qemu.path;
				environmentVariables = {
					EFI_DIR = "${pkgs.OVMF.fd}/FV/";
					STORAGE_URL = "http://localhost:9000";
				};
			};
		};
	};
	virtualisation = {
		docker.enable = true;
		oci-containers.backend = "docker";
	};
	environment.systemPackages = with pkgs; [
		curl
		gawk
		git
		minio-client
		p7zip
		packer
		pup
		(python3.withPackages (p: with p; [ pip pyyaml virtualenv ]) )
		qemu_full
		qemu_kvm
		shellcheck
		unzip
		xorriso
		vagrant
		wget
	];
}
