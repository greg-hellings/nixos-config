{ config, pkgs, ... }:

{
	age.secrets.nextcloudadmin.file = ../../secrets/nextcloudadmin.age;
	age.secrets.nextcloudadmin.owner = "nextcloud";

	services.nextcloud = {
		enable = true;
		package = pkgs.nextcloud27;
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

	greg.backup.jobs.nextcloud-bkup = {
		src = "/var/lib/nextcloud";
		dest = "nextcloud-backup";
		user = "nextcloud";
	};
}
