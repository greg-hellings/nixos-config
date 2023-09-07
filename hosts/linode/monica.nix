{ config, ... }:

{
	services.monica = {
		enable = true;
		appKeyFile = config.age.secrets.monica.path;
		appURL = "https://people.thehellings.com";
		database = {
			port = 5432;
		};
		nginx = {
			addSSL = true;
			enableACME = true;
			serverAliases = [ "people.thehellings.com" ];
		};
	};

	age.secrets.monica = {
		file = ../../secrets/monica.age;
		owner = "monica";
	};

	greg.backup.jobs.monica = {
		src = "/var/lib/monica";
		dest = "monica";
		user = "monica";
	};
}
