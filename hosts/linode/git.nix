{ config, pkgs, ... }:

let
	srcDomain = "src.thehellings.com";
	ciDomain = "ci.thehellings.com";
	ciPort = "17080";
	droneDir = "/var/lib/drone";
	execWorkDir = "/var/lib/drone-exec";
	droneWorkerEnvironment = {
		DRONE_RPC_PROTO = "https";
		DRONE_RPC_HOST = ciDomain;
		DRONE_RUNNER_CAPACITY = "2";
		DRONE_RUNNER_NAME = "docker";
	};
in {

	environment.systemPackages = [ pkgs.drone-runner-exec ];
	##########################################################################################
	###########
	#                       GIT SERVICES
	##########
	##########################################################################################
	services.forgejo = rec {
		enable = true;
		appName = "Greg's Sources";
		database = {
			type = "postgres";
			user = "forgejo";
		};
		dump = {
			enable = true;
			type = "tar.xz";
		};
		settings = {
			server = rec {
				ROOT_URL = "https://${DOMAIN}/";
				DOMAIN = srcDomain;
				HTTP_PORT = 3001;
			};
			service.DISABLE_REGISTRATION = pkgs.lib.mkForce true;
			session.COOKIE_SECURE = pkgs.lib.mkForce true;
			log.level = "Info";
		};
	};

	greg.proxies."${srcDomain}" = {
		target = "${config.services.forgejo.settings.server.PROTOCOL}://${config.services.forgejo.settings.server.DOMAIN}:${toString config.services.forgejo.settings.server.HTTP_PORT}";
		ssl = true;
		genAliases = false;
	};

	greg.backup.jobs.forgejo = {
		src = config.services.forgejo.dump.backupDir;
		dest = "forgejo";
		user = "forgejo";
	};

	services.logrotate = {
		enable = true;
		settings = {
			forgejo = {
				enable = true;
				files = "${config.services.forgejo.dump.backupDir}/*";
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
					DRONE_LOGS_DEBUG = "true";
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
				image = "drone/drone:2.17";
				ports = [ "${ciPort}:80" ];
				volumes = [ "${droneDir}:/data" ];
			};

			"drone-docker" = {
				environment = droneWorkerEnvironment;
				environmentFiles = [
					"/run/agenix/drone"
				];
				extraOptions = [ "--pull=newer" ];
				image = "drone/drone-runner-docker:1.8";
				volumes = [ "/run/podman/podman.sock:/var/run/docker.sock" ];
			};
		};
	};

	systemd.services = {
		"podman-drone".serviceConfig = {
			StateDirectory = "drone";
			StateDirectoryMode = pkgs.lib.mkForce "0777";
			WorkingDirectory = droneDir;
		};

		"drone-exec-runner" = {
			environment = droneWorkerEnvironment;
			description = "Drone pipeline runner that executes locally";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			path = with pkgs; [
				bash
				drone-runner-exec
				git
				podman
			];

			preStart = ''
				mkdir -p ${execWorkDir}
				cat /run/agenix/drone > ${execWorkDir}/conf.env
				echo "" >> ${execWorkDir}/conf.env
			'';
			script = "exec ${pkgs.drone-runner-exec}/bin/drone-runner-exec daemon ${execWorkDir}/conf.env";

			serviceConfig = {
				StateDirectory = "drone-exec";
				StateDirectoryMode = pkgs.lib.mkForce "0777";
			};
		};
	};

	greg.proxies."${ciDomain}" = {
		target = "http://localhost:${ciPort}";
		ssl = true;
		genAliases = false;
	};

	##########################################################################################
	###########
	#                       CI WORKERS
	##########
	##########################################################################################
	virtualisation.podman = {
		enable = true;
		dockerCompat = true;
	};
}
