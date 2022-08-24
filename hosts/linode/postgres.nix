{ config, pkgs, ... }:

{
	services.postgresql = {
		enable = true;
		checkConfig = true;
		ensureDatabases = [ "nextcloud" ];
		initialScript = pkgs.writeText "create-matrix-db.sql" ''
			CREATE ROLE "matrix-synapse" WITH LOGIN;
			CREATE DATABASE "synapse" WITH OWNER "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C";
			GRANT ALL PRIVILEGES ON DATABASE "synapse" TO "matrix-synapse";
		'';  # These are done manually in order to set the LC_COLLATE values properly
		ensureUsers = [ {
			name = "nextcloud";
			ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
		} {
			name = "root";
			ensurePermissions."ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
		} ];
		settings = {
			log_connections = true;
			log_statement = "all";
			logging_collector = true;
		};
		identMap = ''
root root postgres
'';
	};

	services.postgresqlBackup = {
		enable = true;
		databases = [
			"nextcloud"
			"matrix-synapse"
		];
	};

	services.logrotate = {
		enable = true;
		settings = {
			postgresBackup = {
				enable = true;
				files = "${config.services.postgresqlBackup.location}/*.gz";
			};
			postgresLog = {
				enable = true;
				files = "/var/lib/postgresql/*/log/*.log";
			};
		};
	};

	greg.backup.jobs.postgresql = {
		src = "/var/backup/postgresql";
		dest = "linode-postgres";
		user = "postgres";
	};
}
