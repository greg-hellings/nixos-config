{
  pkgs,
  pkgs',
  lib,
  config,
  ...
}:

let
  homepage = "127.0.0.1:30080";
  nextcloudPort = 8080;
  sshPort = 2222;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  age.secrets = {
    acme.file = ../../../secrets/acme.age;
    nextcloudadmin = {
      file = ../../../secrets/nextcloudadmin.age;
      owner = "nextcloud";
    };
  };

  environment.systemPackages = with pkgs; [
    bind
    graphviz
    nix-du
    pgloader
    podman-compose
    pkgs'.upgrade-pg-cluster
  ];

  greg = {
    backup.jobs = {
      nextcloud-bkup = {
        src = "/var/lib/nextcloud";
        dest = "nextcloud-backup";
        pre = lib.getExe (
          pkgs.writeShellApplication {
            name = "nextcloud-backup-pre";
            runtimeInputs = [ config.services.nextcloud.occ ];
            text = "nextcloud-occ maintenance:mode --on";
          }
        );
        post = lib.getExe (
          pkgs.writeShellApplication {
            name = "nextcloud-backup-post";
            runtimeInputs = [ config.services.nextcloud.occ ];
            text = "nextcloud-occ maintenance:mode --off";
          }
        );
      };
      greg-postgresql-backup = {
        src = config.services.postgresqlBackup.location;
        dest = "linode-postgres";
      };
    };
    gitea-runner = {
      enable = false;
      extraLabels = [
        "vps:host"
        "blog:host"
      ];
    };
    home = false;
    linode.enable = true;
    nebula = {
      enable = true;
      isLighthouse = true;
    };
    tailscale.enable = true;
  };

  networking = {
    domain = "thehellings.com";
    firewall.allowedTCPPorts = [
      sshPort
      80
      443
    ];
    hostName = "linode";
    nameservers = [
      "10.157.0.2"
      "100.96.198.104"
    ];
    networkmanager.enable = lib.mkForce false;
  };

  programs.ssh.extraConfig = lib.strings.concatStringsSep "\n" [
    "Host chronicles.shire-zebra.ts.net"
    "    User backup"
    "    IdentityFile /etc/ssh/backup_ed25519"
    "    StrictHostKeyChecking no"
    "    UserKnownHostsFile /dev/null"
  ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsPropagationCheck = false;
      dnsResolver = "92.123.95.3:53,92.123.94.3:53,92.123.94.2:53,92.123.95.4:53,92.123.95.2:53";
      email = "greg.hellings@gmail.com";
      extraLegoRunFlags = [ "--ipv4only" ]; # Force IPv4 only
      #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
    certs."thehellings.com" = {
      dnsProvider = "linode";
      environmentFile = config.age.secrets.acme.path;
      extraDomainNames = [
        "*.thehellings.com"
      ];
    };
  };

  services = {

    anubis = {
      instances = {
        git = {
          enable = true;
          settings = {
            BIND = "/run/anubis/anubis-git/anubis.sock";
            COOKIE_DOMAIN = "thehellings.com";
            SERVE_ROBOTS_TXT = true;
            SLOG_LEVEL = "DEBUG";
            TARGET = "http://git.k3s.nebula.thehellings.com";
          };
        };
      };
    };

    haproxy = {
      enable = true;
      config = ''
        global
          nbthread 4
          maxconn 80
          log /dev/log local0

        defaults
          timeout connect 500s
          timeout client 500s
          timeout server 1h

        listen gitsshd
          bind *:${toString sshPort}
          timeout client 1h
          mode tcp
          server git-isaiah isaiah.nebula.thehellings.com:32222
          server git-jeremiah jeremiah.nebula.thehellings.com:32222
          server git-zeke zeke.nebula.thehellings.com:32222

        frontend https
          bind *:80
          bind *:443 ssl crt ${config.security.acme.certs."thehellings.com".directory}/full.pem

          http-request redirect scheme https unless { ssl_fc }
          http-request add-header X-Forwarded-Proto https

          http-response replace-header ^Set-Cookie:\ (.*) Set-Cookie \1;\ Secure

          option http-server-close
          option http-keep-alive

          #option httplog
          #declare capture response len 80
          #http-response capture res.hdr(Location) id 0

          use_backend git if { hdr(host) -i src.thehellings.com }
          use_backend git if { req_ssl_sni -i src.thehellings.com }
          use_backend next if { hdr(host) -i next.thehellings.com }
          use_backend next if { req_ssl_sni -i next.thehellings.com }
          use_backend matrix if { hdr(host) -i matrix.thehellings.com }
          use_backend matrix if { req_ssl_sni -i matrix.thehellings.com }
          use_backend web if { hdr(host) -i thehellings.com }
          use_backend web if { req_ssl_sni -i thehellings.com }

        backend git
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          http-request set-header Host git.k3s.nebula.thehellings.com
          server git-isaiah isaiah.nebula.thehellings.com:80
          server git-jeremiah jeremiah.nebula.thehellings.com:80
          server git-zeke zeke.nebula.thehellings.com:80

        backend matrix
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          http-request set-header Host matrix.k3s.nebula.thehellings.com
          server git-isaiah isaiah.nebula.thehellings.com:80
          server git-jeremiah jeremiah.nebula.thehellings.com:80
          server git-zeke zeke.nebula.thehellings.com:80

        backend web
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          server web-container ${homepage}

        backend next
          log global
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          #http-response replace-value Location http://localhost:${builtins.toString nextcloudPort}/(.*) https://next.thehellings.com/\2
          server nextcloud 127.0.0.1:${builtins.toString nextcloudPort}
      '';
    };

    immich-public-proxy = {
      enable = true;
      immichUrl = "https://immich.shire-zebra.ts.net";
    };

    logrotate = {
      enable = true;
      settings = {
        postgresBackup = {
          enable = true;
          files = "${config.services.postgresqlBackup.location}/*.gz";
        };
        postgresLog = {
          enable = true;
          files = "/var/lib/postgresql/*/log/*.log";
          compress = true;
          compresscmd = "${pkgs.xz}/bin/xz";
        };
      };
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud33;
      appstoreEnable = true;
      hostName = "localhost";
      https = false;
      config = {
        adminpassFile = config.age.secrets.nextcloudadmin.path;
        adminuser = "greg";
        dbhost = "/run/postgresql";
        dbtype = "pgsql";
      };
      settings = {
        default_phone_region = "US";
        overwriteprotocol = "http";
        trusted_domains = [ "next.thehellings.com" ];
        trusted_proxies = [
          "localhost"
          "127.0.0.1"
        ];
      };
    };

    # Move to :8080 so that we can run haproxy as the primary HTTP service
    nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
      {
        addr = "127.0.0.1";
        port = nextcloudPort;
      }
    ];

    openssh.settings.PasswordAuthentication = false;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      checkConfig = true;
      ensureDatabases = [ "nextcloud" ];
      #initialScript = pkgs.writeText "create-matrix-db.sql" ''
      #	CREATE ROLE "matrix-synapse" WITH LOGIN;
      #	CREATE DATABASE "synapse" WITH OWNER "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C";
      #	GRANT ALL PRIVILEGES ON DATABASE "synapse" TO "matrix-synapse";
      #'';  # These are done manually in order to set the LC_COLLATE values properly
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
      settings = {
        log_connections = true;
        log_statement = "all";
        logging_collector = true;
        log_filename = "postgresql.log";
      };
      identMap = ''
        root root postgres
      '';
    };

    postgresqlBackup = {
      enable = true;
      databases = [ "nextcloud" ];
    };
  };

  systemd.services = {
    haproxy = {
      after = [
        "nextcloud.service"
        "network-online.target"
      ];
      wants = [
        "nextcloud.service"
        "network-online.target"
      ];
    };
  };

  users.users.haproxy.extraGroups = [ config.security.acme.certs."thehellings.com".group ];

  # Actually serve the content from here
  virtualisation.oci-containers = {
    backend = "podman";
    containers."homepage" = {
      image = "src.thehellings.com/greg/homepage:latest";
      ports = [ "${homepage}:80" ];
    };
  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
