{ lib, config, pkgs, ... }:

let
	cfg = config.greg.backup;

	where = j: "${config.services.syncthing.dataDir}/${j.dest}";

	makeSyncFolders = name: job: {
		devices = [ "chronicles" ];
		enable = true;
		id = job.id;
		label = job.dest;
		path = where job;
		type = "sendonly";
	};

	makeRestic = name: job: let
		who = "${config.services.syncthing.user}:${config.services.syncthing.group}";
	in rec {
		initialize = true;
		passwordFile = config.age.secrets.restic-pw.path;
		paths = [ job.src ];
		repository = where job;
		backupCleanupCommand = ''${pkgs.coreutils}/bin/chown -R ${who} "${repository}"'';
	};

in with lib; {
	options = {
		greg.backup = {
			jobs = mkOption {
				default = {};

				type = with types; attrsOf (submodule (
					{ name, config, options, ... }:
					{
						options = {
							src = mkOption {
								type = types.str;
								description = "Local path (string form) to backup from";
							};

							dest = mkOption {
								type = types.str;
							};

							id = mkOption {
								type = types.str;
								description = "The unique folder ID for this";
							};
						};
					}
				));
			};
		};
	};

	config = mkIf ( ( attrValues cfg.jobs ) != [] )
	{
		age.secrets = {
			restic-pw.file = ../../secrets/restic-pw.age;
			restic-env.file = ../../secrets/restic-env.age;
		};
		greg.syncthing = {
			enable = true;
		};
		services = {
			syncthing.settings.folders = mapAttrs makeSyncFolders cfg.jobs;
			restic.backups = mapAttrs makeRestic cfg.jobs;
		};
	};
}
