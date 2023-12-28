inputs:
{ config, pkgs, ... }:
let
	extraPackages = with pkgs; [
		curl
		gawk
		git
		packer
		pup
		(python3.withPackages (p: with p; [ pip pyyaml virtualenv ]))
		qemu_full
		qemu_kvm
		shellcheck
		vagrant
		xonsh
		xorriso
	];
in {
	imports = [
		inputs.agenix.nixosModules.default
	];
	age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
	age.secrets.qemu-runner-reg-1 = {
		file = ../../secrets/gitlab/myself-qemu-runner-reg-1.age;
		owner = "root";
	};

	networking.useHostResolvConf = pkgs.lib.mkForce false;
	networking.nameservers = [ "100.100.100.100" ];
	services.resolved.enable = true;

	environment.systemPackages = extraPackages;

	services.gitlab-runner = {
		enable = true;
		settings.concurrent = 5;
		services.shell = {
			executor = "shell";
			registrationConfigFile = config.age.secrets.qemu-runner-reg-1.path;
			tagList = [ "shell" "qemu" ];
		};
	};
	virtualisation.libvirtd = {
		enable = true;
		onBoot = "ignore";
	};

	systemd.services = {
		gitlab-runner = {
			wants = [ "network-online.target" "systemd-resolved.service" ];
			after = [ "network.target" "network-online.target" "systemd-resolved.service" ];
		};
		libvirtd.serviceConfig = {
			DevicePolicy = "auto";
			DeviceAllow = [ "/dev/kvm" "/dev/mem" ];
			PrivateDevices = false;
			ProtectKernelModules = false;
		};
	};

	system.stateVersion = "24.05";
}
