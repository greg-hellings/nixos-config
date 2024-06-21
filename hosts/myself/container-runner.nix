{ inputs, name, extra ? {}, packages ? [], overlays }:

({ config, pkgs, lib, ... }:
let
	py = (pkgs.python3.withPackages (p: with p; [
		pip
		pyyaml
		virtualenv
	]));
in (
lib.attrsets.recursiveUpdate {

	imports = [
		inputs.agenix.nixosModules.default
		inputs.self.modules.nixosModule
	];

	nixpkgs.overlays = overlays;

	greg.tailscale.enable = true;

	age = {
		identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
		secrets.runner-reg = {
			file = ../../secrets/gitlab/myself-${name}-runner-reg.age;
			owner = "gitlab-runner";
		};
	};

	environment.systemPackages = with pkgs; [
		curl
		gawk
		git
		minio-client
		p7zip
		packer
		pup
		py
		shellcheck
		unzip
		xonsh
		xorriso
		vagrant
		wget
	] ++ packages;

	networking = {
		useHostResolvConf = pkgs.lib.mkForce false;
		nameservers = [ "100.100.100.100" ];
	};

	nixpkgs.config.allowUnfree = true;

	users.users.gitlab-runner = {
		isSystemUser = true;
		group = "kvm";
		extraGroups = [ "kvm" ];
	};

	services = {
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
						STORAGE_URL = "http://localhost:9000";
					};
				};
			};
		};
		resolved.enable = true;
	};

	systemd.services.gitlab-runner = {
		wants = [
			"network-online.target"
			"systemd-resolved.service"
		];
		after = [
			"network.target"
			"network-online.target"
			"systemd-resolved.service"
		];
		serviceConfig = {
			DevicePolicy = lib.mkForce "auto";
			PrivateDevices = false;
			ProtectKernelModules = false;
			DevicesAllow = [ "/dev/kvm" "/dev/mem" ];
			DynamicUser = lib.mkForce false;
			User = "root";
			Group = "kvm";
		};
	};

	system.stateVersion = lib.mkForce "24.05";
}

extra
)  # End of attrsets.recursiveUpdate
)  # End of outter function wrapper
