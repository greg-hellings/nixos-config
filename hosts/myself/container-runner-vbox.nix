{ inputs, name, extra ? {} }:

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
	];

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
		p7zip
		packer
		pup
		py
		shellcheck
		unzip
		xorriso
		vagrant
		wget
	];

	networking = {
		useHostResolvConf = pkgs.lib.mkForce false;
		nameservers = [ "100.100.100.100" ];
	};

	nixpkgs.config.allowUnfree = true;

	services = {
		gitlab-runner = {
			enable = true;
			settings.concurrent = 5;
			services = {
				shell = {
					executor = "shell";
					limit = 5;
					registrationConfigFile = config.age.secrets.runner-reg.path;
					tagList = [ "shell" name ];
				};
			};
		};
		resolved.enable = true;
	};

	systemd.services.gitlab-runner = {
		wants = [ "network-online.target" "systemd-resolved.service" ];
		after = [ "network.target" "network-online.target" "systemd-resolved.service" ];
	};

	system.stateVersion = "24.05";
}

extra
)  # End of attrsets.recursiveUpdate
)  # End of outter function wrapper
