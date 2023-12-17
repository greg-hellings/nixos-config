{ inputs, name, extra}:

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
			packer
			pup
			py
			shellcheck
			xorriso
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
			wants = [ "network-online.target" ];
			after = [ "network.target" "network-online.target" ];
			serviceConfig = {
				User = "root";
				DynamicUser = lib.mkForce false;
			};
		};

		system.stateVersion = "24.05";
		users.users.gitlab-runner = {
			isNormalUser = true;
			group = "gitlab-runner";
			extraGroups = [
				"root"
				"sudo"
				"vboxusers"
				"wheel"
			];
		};
		users.groups.gitlab-runner = {};
	}

	extra
)  # End of attrsets.recursiveUpdate
)  # End of outter function wrapper
