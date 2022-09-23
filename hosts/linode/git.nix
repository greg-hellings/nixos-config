{ config, ... }:

{
	services.gitea = rec {
		enable = true;
		appName = "Greg's Sources";
		cookieSecure = true;
		database = {
			type = "postgres";
			user = "gitea";
		};
		disableRegistration = true;
		domain = "src.thehellings.com";
		dump = {
			enable = true;
			type = "tar.xz";
		};
		rootUrl = "https://${domain}/";
	};

	greg.proxies."src.thehellings.com" = {
		target = "http://localhost:${toString config.services.gitea.httpPort}";
		ssl = true;
		genAliases = false;
	};

	greg.backup.jobs.gitea = {
		src = config.services.gitea.dump.backupDir;
		dest = "gitea";
		user = "gitea";
	};

	services.logrotate = {
		enable = true;
		settings = {
			gitea = {
				enable = true;
				files = "${config.services.gitea.dump.backupDir}/*";
			};
		};
	};
}
