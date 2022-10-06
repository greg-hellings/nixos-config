{ config, pkgs, ... }:

let
	srcDomain = "src.thehellings.com";
	ciDomain = "ci.thehellings.com";
	ciPort = "17080";
	droneDir = "/var/lib/drone";
in {

	##########################################################################################
	###########
	#                       GIT SERVICES
	##########
	##########################################################################################
	services.gitea = rec {
		enable = true;
		appName = "Greg's Sources";
		cookieSecure = true;
		database = {
			type = "postgres";
			user = "gitea";
		};
		disableRegistration = true;
		domain = srcDomain;
		dump = {
			enable = true;
			type = "tar.xz";
		};
		rootUrl = "https://${domain}/";
	};

	greg.proxies."${srcDomain}" = {
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

	##########################################################################################
	###########
	#                       CI SERVICES
	##########
	##########################################################################################

	# Service user
	users.users.drone = {
		isSystemUser = true;
		group = "drone";
		home = droneDir;
	};
	users.groups.drone = {};

	# Environment secrets
	age.secrets.drone = {
		file = ../../secrets/drone.age;
		owner = "root";
	};

	virtualisation.oci-containers = {
		backend = "podman";
		containers = {
			"drone" = {
				environment = {
					DRONE_GITEA_SERVER = "https://${srcDomain}";
					DRONE_SERVER_HOST = ciDomain;
					DRONE_SERVER_PROTO = "https";
					DRONE_SERVER_PROXY_HOST = ciDomain;
					DRONE_SERVER_PROXY_PROTO = "https";
					DRONE_TLS_AUTOCERT = "false";  # Suppress it generating SSL certificates, as our proxy handles that
				};
				environmentFiles = [
					"/run/agenix/drone"
				];
				extraOptions = [ "--pull=newer" ];
				image = "drone/drone:2.13";
				ports = [ "${ciPort}:80" ];
				volumes = [ "${droneDir}:/data" ];
			};
		};
	};

	systemd.services."podman-drone".serviceConfig = {
		StateDirectory = "drone";
		StateDirectoryMode = pkgs.lib.mkForce "0777";
		WorkingDirectory = droneDir;
	};

	greg.proxies."${ciDomain}" = {
		target = "http://localhost:${ciPort}";
		ssl = true;
		genAliases = false;
	};
}
