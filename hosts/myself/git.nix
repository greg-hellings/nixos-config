{ config, pkgs, lib, ... }:

let
	extraPackages = with pkgs; [
		config.virtualisation.virtualbox.host.package
		curl
		gawk
		packer
		pup
		(python3.withPackages (p: with p; [ pip virtualenv ]))
		qemu_full
		qemu_kvm
		xonsh
		xorriso
	];

	secretsList = [
		"secret"
		"otp"
		"db"
		"jws"
	];

	secretsPaths = {
		secret = "/var/lib/secret";
		otp    = "/var/lib/otp";
		db     = "/var/lib/db";
		jws    = "/var/lib/jws";
		key    = "/var/lib/registry-key";
		cert   = "/var/lib/registry-cert";
	};

	registryPort = 8001;
in  {
	age.secrets = {
		gitlab-secret.file = ../../secrets/gitlab/secret.age;
		gitlab-otp.file = ../../secrets/gitlab/otp.age;
		gitlab-db.file = ../../secrets/gitlab/db.age;
		gitlab-jws.file = ../../secrets/gitlab/jws.age;
		gitlab-key.file = ../../secrets/gitlab/key.age;
		gitlab-cert.file = ../../secrets/gitlab/cert.age;
	};

	containers.gitlab = {
		autoStart = true;
		bindMounts = {
			"/var/gitlab/state" = {
				hostPath = "/var/lib/gitlab";
			};
			"${secretsPaths.secret}".hostPath = config.age.secrets.gitlab-secret.path;
			"${secretsPaths.otp}".hostPath    = config.age.secrets.gitlab-otp.path;
			"${secretsPaths.db}".hostPath     = config.age.secrets.gitlab-db.path;
			"${secretsPaths.jws}".hostPath    = config.age.secrets.gitlab-jws.path;
			"${secretsPaths.key}".hostPath    = config.age.secrets.gitlab-key.path;
			"${secretsPaths.cert}".hostPath   = config.age.secrets.gitlab-cert.path;
		};
		privateNetwork = true;
		hostAddress = "192.168.200.1";
		localAddress = "192.168.20..2";
		config = { config, pkgs, ... }: {
			services = {
				gitlab = {
					enable = true;
					backup = {
						keepTime = 288;
						startAt = [ "03:00" ];
					};
					host = "10.42.1.6";  # Just for now...
					https = false;
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
						certFile = secretsPaths.cert;
						keyFile = secretsPaths.key;
						externalPort = registryPort;
					};
					secrets = {
						secretFile = secretsPaths.secret;
						otpFile    = secretsPaths.otp;
						dbFile     = secretsPaths.db;
						jwsFile    = secretsPaths.jws;
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
					logfile = "/var/log/redis-gitlab.log";
				};
			};
			system.stateVersion = "24.05";
		};
	};
}
