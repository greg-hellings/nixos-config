{ config, pkgs, ... }:

{
	age.secrets.nextcloudadmin.file = ../../secrets/nextcloudadmin.age;
	age.secrets.nextcloudadmin.owner = "nextcloud";

	services.nextcloud = {
		enable = true;
		package = pkgs.nextcloud23;
		appstoreEnable = true;
		hostName = "next.${config.networking.domain}";
		https = true;
		config = {
			adminpassFile = config.age.secrets.nextcloudadmin.path;
			adminuser = "greg";
			dbhost = "/run/postgresql";
			dbtype = "pgsql";
			defaultPhoneRegion = "US";
			overwriteProtocol = "https";
		};
	};

	services.nginx.virtualHosts."next.thehellings.com" = {
		forceSSL = true;
		enableACME = true;
	};

	services.syncthing.folders."nextcloud-backup" = {
		path = "${config.services.nextcloud.datadir}";
		enable = true;
		devices = [ "nas" ];
	};

	services.cron.systemCronJobs = [
		"59 2 * * * root chmod -R a+r ${config.services.syncthing.folders.nextcloud-backup.path} && find ${config.services.syncthing.folders.nextcloud-backup.path} -type d -exec chmod a+x '{}' \\;"
	];
}
