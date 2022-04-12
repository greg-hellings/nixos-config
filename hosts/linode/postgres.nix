{ config, ... }:

{
	services.postgresql = {
		enable = true;
		checkConfig = true;
		ensureDatabases = [ "synapse" "nextcloud" ];
		ensureUsers = [ {
			name = "synapse";
			ensurePermissions."DATABASE synapse" = "ALL PRIVILEGES";
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
root root root
'';
	};

	services.postgresqlBackup.enable = true;

	services.logrotate = {
		enable = true;
		paths = {
			postgres = {
				enable = true;
				path = "${config.services.postgresqlBackup.location}/*.gz";
			};
		};
	};

	services.syncthing.folders."postgres-backups" = {
		path = "${config.services.postgresqlBackup.location}";
		enable = true;
		devices = [ "nas" ];
	};
}
