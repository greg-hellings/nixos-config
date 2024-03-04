{ lib, config, pkgs, ... }:

let
	cfg = config.greg.backup;

	makeTimer = name: job: {
		timerConfig.OnCalendar = "daily";
		wantedBy = [ "timers.target" ];
	};

	makeService = name: job: {
		serviceConfig = {
			User = job.user;
			ExecStartPre = lib.optionalString (job.pre != "") job.pre;
			ExecStart = "${pkgs.rsync}/bin/rsync -avz --delete -e '${pkgs.openssh}/bin/ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null' ${job.src}/ backup@chronicles.shire-zebra.ts.net:/volume1/NetBackup/${job.dest}";
			ExecStartPost = lib.optionalString (job.post != "") job.post;
		};
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

	config = mkIf ( ( attrValues cfg.jobs ) != [] )
	{
		systemd = {
			timers = mapAttrs makeTimer cfg.jobs;
			services = mapAttrs makeService cfg.jobs;
		};
	};
}
