{ inputs, ...}:
{ config, pkgs, lib, ... }: let
	registryPort = 5000;
	vpnIp = "100.78.226.76";
	containerIp = "192.168.200.2";
in {
	imports = [
		inputs.agenix.nixosModules.default
		../../modules/linux/proxy.nix
		../../modules/linux/tailscale.nix
		../../modules/linux/backup.nix
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

	greg.proxies = let
		t = {
			target = "http://unix:/run/gitlab/gitlab-workhorse.socket";
			extraConfig = ''
			proxy_set_header X-Forwarded-Proto https;
			proxy_set_header X-Forwarded-Ssl on;
			'';
		};
	in {
		"${containerIp}" = t;
		"${vpnIp}" = t;
		"git.thehellings.lan" = t;
	};
	greg.tailscale.enable = true;

	virtualisation.docker.enable = true;

	programs.ssh.extraConfig = lib.strings.concatStringsSep "\n" [
		"Host nas"
		"    User backup"
		"    IdentityFile /etc/ssh/duplicity_ed25519"
		"    StrictHostKeyChecking no"
		"    UserKnownHostsFile /dev/null"
	];

	greg.backup.jobs.nas-backup = {
		src = "/var/gitlab/state/backup/";
		dest = "gitlab";
	};

	services = {
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
					trustedProxies = [ "100.109.86.8/32" ];
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
				externalAddress = "registry.thehellings.com";
				externalPort = 443;
			};
			secrets = {
				secretFile = config.age.secrets.gitlab-secret.path;
				otpFile    = config.age.secrets.gitlab-otp.path;
				dbFile     = config.age.secrets.gitlab-db.path;
				jwsFile    = config.age.secrets.gitlab-jws.path;
			};
		};

		nginx.virtualHosts."gitlab.shire-zebra.ts.net" = {
			listen = [ {
				addr = vpnIp;
				port = registryPort;
				ssl = true;
			} ];
			locations."/" = {
				proxyPass = "http://127.0.0.1:5000/";
				recommendedProxySettings = true;
			};
			extraConfig = builtins.concatStringsSep "\n" [
				"ssl_certificate /etc/certs/gitlab.shire-zebra.ts.net.crt ;"
				"ssl_certificate_key /etc/certs/gitlab.shire-zebra.ts.net.key ;"
				"client_max_body_size 250m;"
			];
		};

		# Fetch the SSL certificates for nginx to use
		cron = {
			enable = true;
			systemCronJobs = [ "0 0 1 */2 * cd /etc/certs && tailscale cert gitlab.shire-zebra.ts.net && chown nginx * && systemctl reload nginx" ];
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
		resolved.enable = true;
		openssh.enable = true;
	};

	# Do not start nginx until we have tailscaled up and running, so it can bind
	# to the 100.* addresses
	systemd.services.nginx = {
		after = [
			"tailscaled.service"
			"network.target"
			"network-online.target"
		];
		wants = [
			"tailscaled.service"
			"network.target"
			"network-online.target"
		];
	};
	system.stateVersion = "24.05";
}
