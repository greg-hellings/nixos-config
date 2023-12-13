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
	services = {
		forgejo = rec {
			enable = true;
			package = pkgs.unstable.forgejo;
			database = {
				type = "postgres";
				user = "forgejo";
			};
			dump = {
				enable = true;
				type = "tar.xz";
			};
			settings = {
				actions.ENABLED = true;
				DEFAULT = {
					APP_NAME = "Greg's Sources";
				};
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

		# For now, at least, this is the same as Forgejo's action runner
		gitea-actions-runner.instances = {
			exec = {
				enable = true;
				hostPackages = with pkgs; [
					bashInteractive
					podman
					git
					nodejs
				];
				name = "Linode";
				labels = [
					"native:host"
				];
				tokenFile = config.age.secrets.forgejo-runner.path;
				url = "https://src.thehellings.com";
				settings = {
					log.level = "info";
					runner = {
						file = ".runner";
						capacity = 3;
						envs = {};  # Environment variables
						env_file = ".env";
						timeout = "3h";  # This is the default on Gitea/Forgejo as well
						insecure = false;  # TLS verification
						fetch_timeout = "5s";
						fetch_interval = "2s";
						#labels = [];  # See above
					};
					cache = {
						enabled = true;
						dir = "";  # Default is $HOME/.cache/actcache
						host = "";  # How to access cache from the runner, autodetect
						port = 0;
						external_server = "";  #We are not going externally
					};
					container = {
						network = "";  # Auto-create
						privileged = false;
						options = null;
						workdir_parent = "/workspace";
						valid_volumes = [];
						#docker_host = "";
						force_pull = false;
					};
					host = {
						workdir_parent = null;  # Default $HOME/.cache/act
					};
				};
			};
		};

		logrotate = {
			enable = true;
			settings = {
				forgejo = {
					enable = true;
					files = "${config.services.forgejo.dump.backupDir}/*";
				};
			};
		};
	};

	age.secrets.forgejo-runner = {
		file = ../../secrets/linode-forgejo-runner.age;
		owner = config.systemd.services.gitea-runner-exec.serviceConfig.User;
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

	##########################################################################################
	###########
	#                       CI SERVICES
	##########
	##########################################################################################
	virtualisation.oci-containers = {
		backend = "podman";
	};

	virtualisation.podman = {
		enable = true;
		dockerCompat = true;
	};
}
