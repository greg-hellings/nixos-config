{ config, pkgs, lib, ... }:

{
	services.postgresql = {
		enable = true;
		checkConfig = true;
		ensureDatabases = [
			"dendrite"
			"gitea"
			"monica"
			"nextcloud"
		];
		#initialScript = pkgs.writeText "create-matrix-db.sql" ''
		#	CREATE ROLE "matrix-synapse" WITH LOGIN;
		#	CREATE DATABASE "synapse" WITH OWNER "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C";
		#	GRANT ALL PRIVILEGES ON DATABASE "synapse" TO "matrix-synapse";
		#'';  # These are done manually in order to set the LC_COLLATE values properly
		ensureUsers = [ {
			name = "nextcloud";
			ensureDBOwnership = true;
		} {
			name = "gitea";
			ensureDBOwnership = true;
		} {
			name = "dendrite";
			ensureDBOwnership = true;
		} {
			name = "monica";
			ensureDBOwnership = true;
		} ];
		settings = {
			log_connections = true;
			log_statement = "all";
			logging_collector = true;
			log_filename = "postgresql.log";
		};
		identMap = ''
root root postgres
'';
	};

	services.postgresqlBackup = {
		enable = true;
		databases = [
			"dendrite"
			"gitea"
			"monica"
			"nextcloud"
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
				compress = true;
				compresscmd = "${pkgs.xz}/bin/xz";
			};
		};
	};

	greg.backup.jobs.postgresql = {
		src = "/var/backup/postgresql";
		dest = "linode-postgres";
		user = "postgres";
	};
}
