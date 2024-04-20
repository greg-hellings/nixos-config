{ config, lib, pkgs, ... }:

let
	cfg = config.greg.databases;
	dbs = (lib.attrNames cfg);
in {
	options.greg.databases = lib.mkOption {
		default = {};
		type = with lib.types; attrsOf ( submodule (
			{ name, config, options, ... }: {
				# Options reserved for future expansion
				options = {};
			}
		));
	};

	config = lib.mkIf ( dbs != [] ) {
		services = {
			postgresql = {
				enable = true;
				package = pkgs.postgresql_15;
				checkConfig = true;
				ensureDatabases = dbs;
				ensureUsers = map (db: { name = db; ensureDBOwnership = true; }) dbs;
				settings = {
					log_connections = true;
					log_statement = "all";
					logging_collector = true;
					log_filename = "postgresql.log";
				};
				identMap = "root root postgres";
			};

			postgresqlBackup =  {
				enable = true;
				databases = dbs;
			};

			logrotate = {
				enable = true;
				settings = {
					postgresqlBackup = {
						enable = true;
						files = "${config.services.postgresqlBackup.location}/*.gz";
					};
					postgresLog = {
						enable = true;
						files = "/var/lib/postgresql/*/log/*.log";
						compress = true;
						compresscmd = "${pkgs.xz}/bin/xz";
					};
				};
			};

		};

		greg.backup.jobs.greg-postgresql-backup = {
			src = config.services.postgresqlBackup.location;
			dest = "database-${config.networking.hostName}";
			user = "postgres";
		};
	};
}
