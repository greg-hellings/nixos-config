{ inputs, registryPort, ...}:
{ config, pkgs, lib, ... }: {
	imports = [
		inputs.agenix.nixosModules.default
		../../modules-linux/proxy.nix
	];

	age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
	age.secretsMountPoint = "/run/derp";
	age.secrets = let
		cfg = n: { file = ../../secrets/gitlab/${n}.age; owner = "github"; mode = "0444"; };
	in {
		gitlab-secret = cfg "secret";
		gitlab-otp = cfg "otp";
		gitlab-db = cfg "db";
		gitlab-jws = cfg "jws";
		gitlab-key = cfg "key";
		gitlab-cert = cfg "cert";
	};

	networking = {
		firewall = {
			enable = true;
			allowedTCPPorts = [ 80 registryPort ];
		};
		useHostResolvConf = lib.mkForce false;
	};

	greg.proxies."192.168.200.2" = {
		target = "http://unix:/run/gitlab/gitlab-workhorse.socket";
		extraConfig = ''
		proxy_set_header X-Forwarded-Proto https;
		proxy_set_header X-Forwarded-Ssl on;
		'';
	};

	services = {
		resolved.enable = true;
		openssh.enable = true;
		gitlab = {
			enable = true;
			backup = {
				keepTime = 288;
				startAt = [ "03:00" ];
			};
			host = "src.thehellings.com";
			https = true;
			port = 443;
			extraConfig = {
				gitlab = {
					trustedProxies = [ "192.168.200.1/32" ];
				};
			};
			initialRootEmail = "greg@thehellings.com";
			initialRootPasswordFile = pkgs.writeText "initialRootPassword" "root_password";
			pages = {
				enable = true;
				settings.pages-domain = "pages.thehellings.com";
			};
			puma = {
				threadsMax = 6;
				threadsMin = 2;
				workers = 6;
			};
			redisUrl = "unix:${config.services.redis.servers.gitlab.unixSocket}";
			registry = {
				enable = true;
				certFile = config.age.secrets.gitlab-cert.path;
				keyFile = config.age.secrets.gitlab-key.path;
				externalPort = registryPort;
			};
			secrets = {
				secretFile = config.age.secrets.gitlab-secret.path;
				otpFile    = config.age.secrets.gitlab-otp.path;
				dbFile     = config.age.secrets.gitlab-db.path;
				jwsFile    = config.age.secrets.gitlab-jws.path;
			};
		};

		postgresql = {
			enable = true;
			checkConfig = true;
			ensureDatabases = [ "gitlab" ];
			ensureUsers = [ {
				name = "gitlab";
				ensureDBOwnership = true;
			} ];
			settings = {
				log_connections = true;
				log_statement = "all";
				logging_collector = true;
				log_filename = "postgresql.log";
			};
		};

		redis.servers.gitlab = {
			enable = true;
		};
	};
	system.stateVersion = "24.05";
}
