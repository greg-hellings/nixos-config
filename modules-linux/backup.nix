{ lib, config, pkgs, ... }:

let
	cfg = config.greg.backup;
	backup_key = "backup_keys/id_ed25519";

	makeJob = name: job: {
		paths = job.src;
		encryption.mode = "none";
		environment.BORG_RSH = "ssh -i /etc/${backup_key} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'";
		repo = "ssh://backup@nas.me.ts//volume1/NetBackup/${job.dest}";
		compression = "auto,zstd";
		startAt = "daily";

		user = job.user;
		group = job.group;
		preHook = job.pre;
		postHook = job.post;
	};

	cronJob = name: job:
	let
		binName = "backup-${name}";
		script = pkgs.writeShellScriptBin binName ''
exec 1> >(systemd-cat -t $(basename $0)) 2>&1
set -ex
${job.pre}
${pkgs.rsync}/bin/rsync -avz --delete -e "${pkgs.openssh}/bin/ssh -i /etc/${backup_key} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'" ${job.src}/* backup@chronicles:/volume1/NetBackup/${job.dest}/
${job.post}
'';
	in {
		inherit script;
		cron = "0 1 * * * ${job.user} ${script}/bin/${binName}";
	};

in with lib; {
	options = {
		greg.backup = {
			key = mkOption {
				type = types.path;
				description = "SSH key to use";
				default = ../ssh/id_ed25519;
			};

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

							user = mkOption {
								type = types.str;
								default = "root";
								description = "User to run backup as";
							};

							pre = mkOption {
								type = types.str;
								default = "";
								description = "Commands to run before backup";
							};

							post = mkOption {
								type = types.str;
								default = "";
								description = "Commands to run after backup";
							};
						};
					}
				));
			};
		};
	};

	config = let
		jobs = attrValues ( mapAttrs cronJob cfg.jobs );
	in mkIf ( ( attrValues cfg.jobs ) != [] )
	{
		services.cron = {
			enable = true;
			systemCronJobs = map (e: e.cron) jobs;
		};

		environment.systemPackages = map (e: e.script) jobs;
	};
}
