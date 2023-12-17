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
		xonsh
		xorriso
	];
in {
	imports = [
		inputs.agenix.nixosModules.default
	];
	age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
	age.secrets = let
		file = num: {
			file = ../../secrets/gitlab/myself-qemu-runner-reg-${num}.age;
			owner = "gitlab-runner";
		};
	in {
		qemu-runner-reg-1 = file "1";
		qemu-runner-reg-2 = file "2";
		qemu-runner-reg-3 = file "3";
		qemu-runner-reg-4 = file "4";
		qemu-runner-reg-5 = file "5";
	};

	networking.useHostResolvConf = pkgs.lib.mkForce false;
	networking.nameservers = [ "100.100.100.100" ];
	services.resolved.enable = true;

	environment.systemPackages = extraPackages;

	services.gitlab-runner = {
		enable = true;
		settings.concurrent = 5;
		services = let
			r = num: {
				executor = "shell";
				registrationConfigFile = config.age.secrets."qemu-runner-reg-${num}".path;
				tagList = [ "shell" "qemu" ];
			};
		in {
			shell1 = r "1";
			shell2 = r "2";
			shell3 = r "3";
			shell4 = r "4";
			shell5 = r "5";
		};
	};

	systemd.services.gitlab-runner.wants = [ "network-online.target" ];
	systemd.services.gitlab-runner.after = [ "network.target" "network-online.target" ];

	system.stateVersion = "24.05";
}
