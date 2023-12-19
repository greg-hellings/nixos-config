{ config, pkgs, lib, inputs, ... }:

let

	gitlabStateDir = "/var/lib/gitlab";

	registryPort = 8001;

	container = input: (lib.attrsets.recursiveUpdate {
		bindMounts."/etc/ssh".hostPath = "/etc/ssh";  # For agenix secrets
		privateNetwork = true;
	} input);
in  {
	networking = {
		firewall = {
			enable = true;
			allowedTCPPorts = [ 80 registryPort ];
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

	containers.gitlab = container {
		autoStart = true;
		bindMounts = {
			"/var/gitlab/state" = {
				hostPath = gitlabStateDir;
				isReadOnly = false;
			};
		};
		forwardPorts = [{
			hostPort = 2222;
			containerPort = 22;
		}];
		hostAddress = "192.168.200.1";
		localAddress = "192.168.200.2";
		config = ((import ./container-git.nix) { inherit inputs registryPort; });
	};

	systemd.services = {
		"container@gitlab-runner-qemu" = {
			conflicts = [
				"container@gitlab-runner-vbox.service"
			];
			serviceConfig = {
				DevicePolicy = lib.mkForce "auto";
				ExecPostStop = [ "rmmod kvm_amd kvm" ];
				ExecPreStart = [ "modprobe kvm" ];
			};
		};
		"container@gitlab-runner-vbox" = {
			conflicts = [
				"container@gitlab-runner-qemu.service"
			];
			serviceConfig = {
				DevicePolicy = lib.mkForce "auto";
				ExecPostStop = [ "rmmod vboxnetadp vboxnetflt vboxdrv" ];
				ExecPreStart = [ "modprobe vboxdrv vboxnetadp vboxnetflt" ];
			};
		};
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
		};
		extraFlags = [
			"--property=DeviceAllow=/dev/kvm"
		];
		hostAddress = "192.168.201.1";
		localAddress = "192.168.201.2";
		config = ((import ./container-runner-qemu.nix) inputs);
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
		config = ((import ./container-runner-vbox.nix) {
			inherit inputs;
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
		config = ((import ./container-runner-vbox.nix) {
			inherit inputs;
			name = "shell";
		});
	};

	#####################################################################################
	#################### Local Podman/Docker Runner #####################################
	#####################################################################################
	age.secrets.runner-reg.file = ../../secrets/gitlab/myself-podman-runner-reg.age;
	services.gitlab-runner = {
		enable = false;
		settings.concurrent = 5;
		services = {
			default = {
				executor = "docker";
				registrationConfigFile = config.age.secrets.runner-reg.path;
				dockerImage = "debian:stable";
			};
		};
	};
	virtualisation = {
		docker.enable = true;
		oci-containers.backend = "docker";
	};
	#users.users.gitlab-runner.extraGroups = [ "docker" ];
}
