{ config, pkgs, lib, inputs, ... }:

let
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
		privateNetwork = true;
		hostAddress = "192.168.200.1";
		localAddress = "192.168.200.2";
		config = ((import ./container-git.nix) { inherit inputs registryPort; });
	};
}
