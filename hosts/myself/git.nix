{ config, pkgs, lib, inputs, overlays, ... }:

let

	gitlabStateDir = "/var/lib/gitlab";

	container = input: (lib.attrsets.recursiveUpdate {
		bindMounts."/etc/ssh".hostPath = "/etc/ssh";  # For agenix secrets
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
		"container@gitlab-runner-qemu" = {
			conflicts = [
				"container@gitlab-runner-vbox.service"
			];
			serviceConfig = {
				DevicePolicy = lib.mkForce "auto";
				ExecStopPost = [ "${pkgs.kmod}/bin/rmmod kvm_amd kvm" ];
				ExecStartPre = [
					"${pkgs.kmod}/bin/modprobe kvm"
					"${pkgs.kmod}/bin/modprobe kvm_amd"
				];
			};
		};
		"container@gitlab-runner-vbox" = {
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
		gitlab-runner.serviceConfig.EnvironmentFile = config.age.secrets.docker-auth.path;
	};

	#####################################################################################
	#################### QEmu Runner ####################################################
	#####################################################################################
	containers.gitlab-runner-qemu = container {
		bindMounts = {
			"/dev/kvm" = {
				hostPath = "/dev/kvm";
				isReadOnly = false;
			};
			"/dev/mem" = {
				hostPath = "/dev/mem";
				isReadOnly = false;
			};
		};
		extraFlags = [
			"--property=DeviceAllow=/dev/kvm"
		];
		hostAddress = "192.168.201.1";
		localAddress = "192.168.201.2";
		config = ((import ./container-runner.nix) {
			inherit inputs overlays;
			name = "qemu";
			packages = with pkgs; [ qemu_full qemu_kvm ];
			extra = {
				virtualisation.libvirtd = {
					enable = true;
					onBoot = "ignore";
					package = pkgs.libvirt-greg;
				};
			};
		});
	};

	#####################################################################################
	#################### Virtualbox Runner ##############################################
	#####################################################################################
	containers.gitlab-runner-vbox = container {
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
		config = ((import ./container-runner.nix) {
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
		});
	};

	#####################################################################################
	#################### Local Podman/Docker Runner #####################################
	#####################################################################################
	age.secrets.runner-reg.file = ../../secrets/gitlab/myself-podman-runner-reg.age;
	age.secrets.docker-auth.file = ../../secrets/gitlab/docker-auth.age;
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
					"registry.thehellings.com/*"
					"gitlab.shire-zebra.ts.net:5000/*:*"
				];
				dockerAllowedServices = [
					"docker:*"
					"registry.thehellings.com/*"
					"gitlab.shire-zebra.ts.net:5000/*:*"
				];
				dockerPrivileged = true;
				dockerVolumes = [
					"/certs/client"
					"/cache"
				];
			};
		};
	};
	virtualisation = {
		docker.enable = true;
		oci-containers.backend = "docker";
		virtualbox.host.enable = true;
	};
}
