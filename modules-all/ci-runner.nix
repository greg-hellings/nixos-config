{ config, pkgs, lib, ... }:

let
	cfg = config.greg.ci-runner;
	runnerNames = (builtins.attrNames cfg);
	makeRunner = name: value: {
		enable = true;
		hostPackages = with pkgs; [
			bashInteractive
			podman
			git
			nodejs
		] ++ value.packages;
		labels = lib.mkIf ( builtins.hasAttr "labels" value) value.labels;
		name = config.networking.hostName;
		tokenFile = config.age.secrets.forgejo-runner.path;
		url = "https://src.thehellings.com";
		settings.runner.capacity = value.parallel;
	};

	userName = "gitea-runner";

in with lib; {
	options = {
		greg.ci-runner = mkOption {
			default = {};
			description = "List of gitea/forgejo runners to configure";
			example = ''
				```
				greg.ci-runner.snarfblatt = {
					labels = [ "ubuntu-latest:docker://ubuntu:latest" ];
				};
				```
			'';

			type = with types; attrsOf ( submodule (
				{ name, config, options, ... }:
				{
					options.labels = mkOption {
						type = (types.listOf types.str);
						default = [];
						description = ''List of labels. The syntax is
						more or less going to be something along the lines
						of `<runs-on-label>:docker://<actual docker image>` or
						`native:host` for a system that will support running
						commands directly on the server.'';
					};

					options.packages = mkOption {
						type = (types.listOf types.package);
						default = [];
						description = ''List of extra packages that will be needed
						in the running environment for this worker.'';
					};

					options.parallel = mkOption {
						type = types.int;
						default = 3;
						description = "The maximum number of parallel jobs this runner will support.";
					};
				})
			);
		};
	};

	config = mkIf ( runnerNames != [] ) {
		services.gitea-actions-runner.instances = ( mapAttrs makeRunner cfg);

		age.secrets.forgejo-runner = let
			aName = builtins.elemAt runnerNames 0;
			target = "gitea-runner-${aName}";
		in {
			file = ../secrets/${config.networking.hostName}-forgejo-runner.age;
			owner = userName;
			group = userName;
		};

		users.users."${userName}" = {
			isSystemUser = true;
			group = "${userName}";
		};
		users.groups."${userName}" = {};
	};
}
