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
  vpnIp = "100.117.28.111";
in
{
  imports = [
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
      gitlab-db-password = cfg "db-password";
      gitlab-jws = cfg "jws";
      gitlab-key = cfg "key";
      gitlab-cert = cfg "cert";
      gitlab-salt = cfg "salt";
      gitlab-primary-key = cfg "primary-key";
      gitlab-deterministic-key = cfg "deterministic-key";

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

  greg = {
    backup.jobs.nas-backup = {
      src = "/var/gitlab/state/backup/";
      dest = "gitlab";
    };
    home = true;
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
  };

  networking = {
    hostName = "vm-gitlab"; # Define your hostname.
    firewall.allowedTCPPorts = [
      80
      registryPort
    ];
  };

  services = {
    gitlab = {
      enable = true;
      backup = {
        keepTime = 288;
        startAt = [ "03:00" ];
      };
      databaseHost = "postgres.kubernetes";
      databaseName = "gitlab";
      databaseUsername = "gitlab";
      databasePasswordFile = config.age.secrets.gitlab-db-password.path;
      databaseCreateLocally = false;
      extraConfig = {
        gitlab = {
          trustedProxies = [
            "${vpnIp}/32" # The system itself
            "100.109.86.8/32" # Public server's IP
          ];
        };
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
      host = "src.thehellings.com";
      https = true;
      initialRootEmail = "greg@thehellings.com";
      initialRootPasswordFile = pkgs.writeText "initialRootPassword" "root_password";
      pages = {
        enable = true;
        settings.pages-domain = "pages.thehellings.com";
      };
      port = 443;
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
        activeRecordDeterministicKeyFile = config.age.secrets.gitlab-deterministic-key.path;
        activeRecordPrimaryKeyFile = config.age.secrets.gitlab-primary-key.path;
        activeRecordSaltFile = config.age.secrets.gitlab-salt.path;
        dbFile = config.age.secrets.gitlab-db.path;
        jwsFile = config.age.secrets.gitlab-jws.path;
        otpFile = config.age.secrets.gitlab-otp.path;
        secretFile = config.age.secrets.gitlab-secret.path;
      };
    };

    nginx = {
      enable = true;
      clientMaxBodySize = "25000m";
      virtualHosts = {
        "vm-gitlab.shire-zebra.ts.net" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 443;
              ssl = true;
            }
          ];
          locations."/" = {
            proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            recommendedProxySettings = true;
          };
          extraConfig = ''
            ssl_certificate /etc/certs/vm-gitlab.shire-zebra.ts.net.crt ;
            ssl_certificate_key /etc/certs/vm-gitlab.shire-zebra.ts.net.key ;
            client_max_body_size 10000m ;
          '';
        };
        "registry" = {
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
            ssl_certificate /etc/certs/vm-gitlab.shire-zebra.ts.net.crt ;
            ssl_certificate_key /etc/certs/vm-gitlab.shire-zebra.ts.net.key ;
            client_max_body_size 25000m ;
          '';
          serverAliases = [
            "vm-gitlab.shire-zebra.ts.net"
          ];
        };
      };
    };

    openssh.enable = true;

    postgresql.enable = true;

    qemuGuest.enable = true;

    redis.servers.gitlab = {
      enable = true;
    };

    #resolved.enable = true;
  };

  # Do not start nginx until we have tailscaled up and running, so it can bind
  # to the 100.* addresses
  systemd = {
    services = {
      certRefresh =
        let
          script = pkgs.writeShellApplication {
            name = "cert-refresh";
            runtimeInputs = [ pkgs.tailscale ];

            text = ''
              cd /etc/certs
              tailscale cert vm-gitlab.shire-zebra.ts.net
              chown nginx ./*
              systemctl reload nginx
            '';
          };
        in
        {
          script = lib.getExe script;
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        };

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

    timers = {
      "cert-refresh" = {
        wantedBy = [ "cert-refresh.service" ];
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
      };
    };
  };
  system.stateVersion = lib.mkForce "24.11";
}
