{ config, pkgs, lib, inputs, ... }:

let
	extraPackages = with pkgs; [
		config.virtualisation.virtualbox.host.package
		curl
		gawk
		git
		packer
		pup
		(python3.withPackages (p: with p; [ pip virtualenv ]))
		qemu_full
		qemu_kvm
		shellcheck
		xonsh
		xorriso
	];

	gitlabStateDir = "/var/lib/gitlab";

	registryPort = 8001;
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

	greg.proxies."git.thehellings.lan".target = "http://192.168.200.2";
	
	system.activationScripts.makeGitlabDir = lib.stringAfter [ "var" ] "mkdir -p ${gitlabStateDir} && touch ${gitlabStateDir}/touch";

	containers.gitlab = {
		autoStart = true;
		bindMounts = {
			"/var/gitlab/state" = {
				hostPath = gitlabStateDir;
				isReadOnly = false;
			};
			"/etc/ssh".hostPath = "/etc/ssh";
		};
		forwardPorts = [{
			hostPort = 2222;
			containerPort = 22;
		}];
		privateNetwork = true;
		hostAddress = "192.168.200.1";
		localAddress = "192.168.200.2";
		config = ((import ./container-git.nix) { inherit inputs registryPort; });
	};

	systemd.services."container@gitlab-runner".serviceConfig = {
		DevicePolicy = lib.mkForce "auto";
	};

	containers.gitlab-runner = {
		autoStart = true;
		bindMounts = {
			"/etc/ssh".hostPath = "/etc/ssh";
			"/dev/kvm" = {
				hostPath = "/dev/kvm";
				isReadOnly = false;
			};
		};
		extraFlags = [
			"--property=DeviceAllow=/dev/kvm"
		];
		privateNetwork = true;
		hostAddress = "192.168.201.1";
		localAddress = "192.168.201.2";
		config = { config, pkgs, ... }: {
			imports = [
				inputs.agenix.nixosModules.default
			];
			age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
			age.secrets.qemu-runner-reg = {
				file = ../../secrets/gitlab/myself-qemu-runner-reg.age;
				owner = "gitlab-runner";
			};

			networking.useHostResolvConf = lib.mkForce false;
			networking.nameservers = [ "100.100.100.100" ];
			services.resolved.enable = true;

			environment.systemPackages = extraPackages;

			services.gitlab-runner = {
				enable = true;
				services = {
					shell = {
						executor = "shell";
						limit = 5;
						registrationConfigFile = config.age.secrets.qemu-runner-reg.path;
						tagList = [ "shell" "qemu" ];
					};
				};
			};
			system.stateVersion = "24.05";
		};
	};
}
