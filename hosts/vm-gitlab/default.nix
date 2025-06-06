# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

let
  registryPort = 5000;
  vpnIp = "100.91.131.66";
  containerIp = "192.168.200.2";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  age.secrets =
    let
      cfg = n: {
        file = ../../secrets/gitlab/${n}.age;
        owner = "gitlab";
        group = "gitlab";
        mode = "0444";
      };
    in
    {
      gitlab-secret = cfg "secret";
      gitlab-otp = cfg "otp";
      gitlab-db = cfg "db";
      gitlab-jws = cfg "jws";
      gitlab-key = cfg "key";
      gitlab-cert = cfg "cert";

      minio_access_key_id = {
        file = ../../secrets/minio_access_key_id.age;
        owner = "gitlab";
        group = "gitlab";
        mode = "0444";
      };
      minio_secret_access_key = {
        file = ../../secrets/minio_secret_access_key.age;
        owner = "gitlab";
        group = "gitlab";
        mode = "0444";
      };
    };

  greg.proxies =
    let
      t = {
        target = "http://unix:/run/gitlab/gitlab-workhorse.socket";
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Ssl on;
          client_max_body_size 10000m;
        '';
      };
    in
    {
      "${containerIp}" = t;
      "${vpnIp}" = t;
      "git.thehellings.lan" = t;
    };

  greg.backup.jobs.nas-backup = {
    src = "/var/gitlab/state/backup/";
    dest = "gitlab";
    id = "container-gitlab";
  };

  greg = {
    home = true;
    tailscale.enable = true;
  };


  networking = {
    hostName = "vm-gitlab"; # Define your hostname.
    firewall.allowedTCPPorts = [
      80
      registryPort
    ];
  };

  services = {
    # Fetch the SSL certificates for nginx to use
    cron = {
      enable = true;
      systemCronJobs = [
        "0 0 1 */2 * cd /etc/certs && tailscale cert gitlab.shire-zebra.ts.net && chown nginx * && systemctl reload nginx"
      ];
    };

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
          trustedProxies = [
            "${vpnIp}/32" # The container itself
            "100.115.57.8/32" # Public server's IP
          ];
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
        otpFile = config.age.secrets.gitlab-otp.path;
        dbFile = config.age.secrets.gitlab-db.path;
        jwsFile = config.age.secrets.gitlab-jws.path;
      };

      extraConfig = {
        object_store = {
          enabled = true;
          proxy_download = true; # Tell them to reach out to object storage themselves!
          connection = {
            provider = "AWS";
            endpoint = "http://s3.thehellings.lan:9000";
            region = "us-east-1";
            aws_access_key_id = {
              _secret = config.age.secrets.minio_access_key_id.path;
            };
            aws_secret_access_key = {
              _secret = config.age.secrets.minio_secret_access_key.path;
            };
            path_style = true; # True for MinIO
            aws_signature_version = 2;
          };
          #storage_options = ...;
          objects = builtins.listToAttrs (
            builtins.map
              (
                x: lib.attrsets.nameValuePair x { bucket = "gitlab-${builtins.replaceStrings [ "_" ] [ "-" ] x}"; }
              )
              [
                "artifacts"
                "ci_secure_files"
                "dependency_proxy"
                "external_diffs"
                "lfs"
                "packages"
                "pages"
                "terraform_state"
                "uploads"
              ]
          );
        };
      };
    };

    nginx = {
      clientMaxBodySize = "25000m";
      virtualHosts."gitlab.shire-zebra.ts.net" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = registryPort;
            ssl = true;
          }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:4567/";
          recommendedProxySettings = true;
        };
        extraConfig = ''
          ssl_certificate /etc/certs/gitlab.shire-zebra.ts.net.crt ;
          ssl_certificate_key /etc/certs/gitlab.shire-zebra.ts.net.key ;
          client_max_body_size 10000m ;
        '';
      };
    };

    logrotate = {
      enable = true;
      settings = {
        "/var/lib/postgresql/*/log/*.log" = {
          enable = true;
          compress = true;
          compresscmd = "${pkgs.xz}/bin/xz";
        };
      };
    };

    openssh.enable = true;

    postgresql = {
      enable = true;
      checkConfig = true;
      ensureDatabases = [ "gitlab" ];
      ensureUsers = [
        {
          name = "gitlab";
          ensureDBOwnership = true;
        }
      ];
      settings = {
        log_connections = true;
        log_statement = "all";
        logging_collector = true;
        log_filename = "postgresql.log";
      };
    };

    qemuGuest.enable = true;

    redis.servers.gitlab = {
      enable = true;
    };
    resolved.enable = true;
  };

  # Do not start nginx until we have tailscaled up and running, so it can bind
  # to the 100.* addresses
  systemd.services = {
    nginx = rec {
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wants = after;
      serviceConfig = {
        RestartMaxDelaySec = "30s";
        RestartSteps = "5";
      };
    };
    tailscaled.partOf = [ "network-online.target" ];
  };
  system.stateVersion = lib.mkForce "24.11";
}
