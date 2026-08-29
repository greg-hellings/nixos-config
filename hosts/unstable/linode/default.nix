{
  config,
  lib,
  metadata,
  pkgs,
  pkgs',
  ...
}:

let
  homepage = "127.0.0.1:30080";
  nextcloudPort = 8080;
  sshPort = 2222;
  matrixServer = pkgs.writeText "matrix_server" (
    builtins.toJSON {
      "m.server" = "matrix.thehellings.com:443";
    }
  );
  matrixClient = pkgs.writeText "matrix_client" (
    builtins.toJSON {
      "m.homeserver" = {
        base_url = "https://matrix.thehellings.com";
      };
      "m.identity_server" = {
        base_url = "https://vector.im";
      };
    }
  );
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

  # Historical per-interface bandwidth tracking (5-min granularity, kept for
  # months). This is what's actually missing when diagnosing "traffic was
  # high for the past several hours" reports after the fact — journalctl
  # timestamps only tell you what else was happening, not the traffic curve
  # itself. `vnstat -h`/`vnstat --json h` gives an immediate confirm/deny of
  # a reported window without waiting on live sampling.
  services.vnstat.enable = true;

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
      enable = true;
      labels = [
        "vps:host"
        "blog:host"
        "nixos-linode:host"
      ];
    };
    home = false;
    linode.enable = true;
    nebula = {
      enable = true;
      isLighthouse = true;
      unsafeRoutes = [
        {
          route = "10.42.0.0/16";
          via = metadata.hosts.genesis.nebulaIp;
        }
      ];
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
            TARGET = "http://git.k3s.thehellings.lan";
          };
        };
      };
    };

    # HAProxy (below) is configured with `log /dev/log local0`, which lands
    # in the systemd journal but isn't a growing text file fail2ban's
    # (default) file-based backend can tail. rsyslogd bridges that gap: it
    # reads from the same journal socket journald forwards to (wired up
    # automatically - enabling rsyslogd flips journald's
    # `forwardToSyslog` on by default, see
    # <nixpkgs/nixos/modules/system/boot/systemd/journald.nix>), so
    # routing the `local0` facility to a real file here is enough to give
    # fail2ban's `haproxy` jail (see below) a logpath to watch, without
    # duplicating HAProxy's own logging config.
    rsyslogd = {
      enable = true;
      extraConfig = ''
        local0.* -/var/log/haproxy.log
      '';
    };

    fail2ban = {
      enable = true;
      bantime = "24h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64 128";
        overalljails = true;
      };
      ignoreIP = [
        "100.64.0.0/10"
        "10.157.0.0/16"
        "10.42.0.0/16"
        "99.9.15.123/32"
      ];
      jails = {
        haproxy = {
          # fail2ban ships a "haproxy-http-auth" filter, but no generic
          # "haproxy" one - referencing filter = "haproxy" (as a string,
          # under `.settings` below) pointed at a file that doesn't exist,
          # so the jail failed to load entirely (see
          # `journalctl -u fail2ban`: "Found no accessible config files
          # for 'filter.d/haproxy'" / "Errors in jail 'haproxy'.
          # Skipping..."). Setting `filter` here (top-level, not nested in
          # `.settings`) as an attrset instead of a string name tells the
          # NixOS module to auto-generate
          # /etc/fail2ban/filter.d/haproxy.conf from this content (see
          # `mkFilter` in <nixpkgs/nixos/modules/services/security/fail2ban.nix>).
          #
          # Matches two classes of scanning/bot traffic actually observed
          # hammering this host's logs: naked-TLS-handshake probes (no
          # valid SNI/cipher offer) and requests HAProxy couldn't route to
          # any backend at all (<NOSRV> - typically the same scanners
          # hitting the bare IP without a matching Host/SNI ACL).
          filter = {
            INCLUDES.before = "common.conf";
            Definition = {
              _daemon = "haproxy";
              # %(__prefix_line)s (from common.conf) consumes the syslog
              # preamble rsyslogd/journald adds ("Aug 18 04:20:07 linode
              # haproxy[1292]: "), matching the same idiom as fail2ban's
              # stock haproxy-http-auth.conf filter above.
              failregex = ''
                ^%(__prefix_line)s<HOST>:\d+ \[\S+\] \S+/\d+: (SSL handshake failure|Connection closed during SSL handshake)
                ^%(__prefix_line)s<HOST>:\d+ \[\S+\] \S+~? \S+/<NOSRV>
              '';
              ignoreregex = "";
            };
          };
          settings = {
            enabled = true;
            # See the rsyslogd config below: HAProxy logs to the `local0`
            # syslog facility, which journald receives but can't be
            # tailed as a growing text file the way fail2ban's file
            # backend needs. rsyslogd is configured to write local0 out
            # to this real file instead.
            logpath = "/var/log/haproxy.log";
            port = "http,https";
            # Without this, fail2ban's systemd backend (used because
            # `backend = systemd` is set globally in the jail defaults -
            # see `journalctl -u fail2ban`: "Jail started without
            # 'journalmatch' set. Jail regexs will be checked against all
            # journal entries...") scans every journal entry from every
            # unit on the host, not just haproxy's, on every poll cycle.
            # Confirmed via `journalctl --since -1h | wc -l` vs
            # `journalctl --since -1h SYSLOG_IDENTIFIER=haproxy | wc -l`:
            # haproxy is ~91% of all journal traffic on this host, so the
            # existing waste is small today, but it scales with unrelated
            # services' log volume (unbounded) rather than haproxy's, and
            # will only get worse as more services are added to this box.
            # Scoping the match narrows fail2ban's systemd-backend reads
            # to just haproxy's entries, mirroring the stock `sshd` filter
            # (see /etc/fail2ban/filter.d/sshd.conf), which pins both
            # `_SYSTEMD_UNIT` and `_COMM` for the same reason.
            journalmatch = "_SYSTEMD_UNIT=haproxy.service + _COMM=haproxy";
          };
        };
      };
      maxretry = 5;
    };

    haproxy = {
      enable = true;
      config = ''
        global
          nbthread 2
          maxconn 3000
          # haproxy's own open-fd budget is roughly 2 fds per proxied
          # connection (client + server side) plus listeners/logging, so at
          # maxconn=3000 it needs ~6000+ fds available. The systemd unit
          # doesn't set LimitNOFILE, so haproxy inherits the distro default
          # soft limit of 1024 -- nowhere near enough headroom once traffic
          # actually approaches maxconn. haproxy can raise its own soft
          # limit up to the (much higher) hard limit at startup via
          # `ulimit-n`, without needing extra process capabilities, so just
          # tell it to do that explicitly instead of relying on the
          # (insufficient) default.
          ulimit-n 8000
          log /dev/log local0

        defaults
          log global
          timeout connect 500s
          timeout client 500s
          timeout server 1h
          # HAProxy defaults to end-to-end keep-alive (client AND server side)
          # unless a proxy overrides it. Bound how long an idle client-facing
          # keep-alive connection is held rather than falling back to
          # "timeout client" (500s).
          #
          # CORRECTION (see #39): this was originally set to 30s as a
          # tidy-up given maxconn=80, without considering client-side
          # connection pooling behavior. That was too aggressive: DAVx5 (and
          # OkHttp-based HTTP clients generally) keep idle pooled
          # connections open for up to 5 minutes client-side before
          # eviction. With a 30s haproxy-side timeout, any client connection
          # idle between 30s-300s got silently closed by haproxy, and the
          # client's next reuse of it produced exactly the "unexpected end
          # of stream"/EOFException class of error this investigation
          # started from - just relocated from the haproxy<->nginx leg
          # (fixed in `backend next` below) to the client<->haproxy leg.
          # Set comfortably above OkHttp's 300s default so a client's own
          # pool eviction always happens first and haproxy is never the one
          # to close a connection the client still thinks is good.
          timeout http-keep-alive 6m

        listen gitsshd
          bind *:${toString sshPort}
          timeout client 1h
          mode tcp
          server git-isaiah isaiah.thehellings.lan:32222
          server git-jeremiah jeremiah.thehellings.lan:32222
          server git-zeke zeke.thehellings.lan:32222

        listen stats
          bind 127.0.0.1:8404
          stats enable
          stats uri /
          stats refresh 10s

        frontend https
          # Explicit backlog matching global maxconn (3000): HAProxy's
          # "expose-fd listeners" hot-reload mechanism (see the stats
          # socket line in the global section) hands the existing kernel
          # listening socket's fd to the new worker on reload rather than
          # re-creating it, which means the socket's listen() backlog is
          # only actually re-applied on a full process restart, not a
          # reload. Observed live on 2026-08-21: `ss -tln` showed the
          # :443 listener's Send-Q (kernel backlog) pinned at 80 -- a
          # leftover from a much older `maxconn 80` config (see the
          # timeout http-keep-alive comment above) -- despite maxconn
          # having been raised to 3000 for a while. Constant internet
          # background scan/bot traffic (see fail2ban's haproxy jail
          # logs -- hundreds of distinct source IPs per few seconds) was
          # enough to overflow that 80-slot accept queue on its own,
          # producing intermittent ECONNRESET/timeout for any in-flight
          # legitimate request (including the Matrix Kuma monitor) even
          # though haproxy itself was healthy and never restarted.
          # Setting backlog explicitly here makes it self-correcting on
          # every reload instead of silently carrying forward a stale
          # value from whatever maxconn happened to be in effect the
          # last time the process was fully restarted.
          bind *:80 backlog 4096
          bind *:443 ssl crt ${config.security.acme.certs."thehellings.com".directory}/full.pem backlog 4096

          # CORRECTION (2026-08-25 Matrix Kuma DOWN flap): the backlog=4096
          # fix above (2026-08-21) only addressed the kernel accept queue
          # overflowing; it does nothing about TLS handshake *CPU* capacity.
          # This box is 2 vCPUs, and constant internet background
          # scan/bot traffic (the same hundreds-of-source-IPs-per-few-seconds
          # noise fail2ban's `haproxy` jail bans -- see below) still gets to
          # spend a full TLS handshake's worth of CPU on this frontend
          # *before* fail2ban's log-tailing ban can react, because fail2ban
          # is inherently reactive (it only acts after enough failregex
          # matches have already been logged). During a burst, that
          # handshake-CPU contention was enough to starve legitimate
          # in-flight handshakes (including the Matrix Kuma monitor's, and
          # our own external re-checks during this triage, which were
          # allow-listed in fail2ban's ignoreIP and therefore never banned,
          # yet still saw ~30% empty-reply/timeout failures against a
          # healthy, unrestarted haproxy and healthy backends). A stick-table
          # connection-rate cap at the frontend rejects a flooding source at
          # the TCP layer, before it costs any TLS handshake CPU, closing
          # the gap fail2ban's reactive banning leaves open.
          stick-table type ip size 200k expire 30s store conn_rate(10s)
          tcp-request connection track-sc0 src
          tcp-request connection reject if { sc_conn_rate(0) gt 40 }

          http-request redirect scheme https unless { ssl_fc }
          http-request add-header X-Forwarded-Proto https

          http-response replace-header ^Set-Cookie:\ (.*) Set-Cookie \1;\ Secure

          option http-server-close
          option http-keep-alive
          option httplog

          #declare capture response len 80
          #http-response capture res.hdr(Location) id 0

          use_backend git if { hdr(host) -i src.thehellings.com }
          use_backend git if { req_ssl_sni -i src.thehellings.com }
          use_backend next if { hdr(host) -i next.thehellings.com }
          use_backend next if { req_ssl_sni -i next.thehellings.com }
          use_backend matrix if { hdr(host) -i matrix.thehellings.com }
          use_backend matrix if { req_ssl_sni -i matrix.thehellings.com }
          use_backend immich if { hdr(host) -i immich.thehellings.com }
          use_backend immich if { req_ssl_sni -i immich.thehellings.com }
          use_backend web if { hdr(host) -i thehellings.com }
          use_backend web if { req_ssl_sni -i thehellings.com }

        backend git
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          http-request set-header Host git.k3s.thehellings.lan
          #server git-isaiah isaiah.thehellings.lan:80
          #server git-jeremiah jeremiah.thehellings.lan:80
          #server git-zeke zeke.thehellings.lan:80
          server anubsis unix@${config.services.anubis.instances.git.settings.BIND}

        backend immich
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          server immich-proxy 127.0.0.1:${builtins.toString config.services.immich-public-proxy.port}

        backend matrix
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          http-request set-header Host matrix.k3s.thehellings.lan
          server git-isaiah isaiah.thehellings.lan:80
          server git-jeremiah jeremiah.thehellings.lan:80
          server git-zeke zeke.thehellings.lan:80

        backend web
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          http-request return status 200 content-type "application/json" file ${matrixClient} hdr "cache-control" "no-cache" if { path /.well-known/matrix/client }
          http-request return status 200 content-type "application/json" file ${matrixServer} hdr "cache-control" "no-cache" if { path /.well-known/matrix/server }
          server web-container ${homepage}

        backend next
          log global
          log-tag next
          mode http
          balance roundrobin
          option accept-unsafe-violations-in-http-response
          retries 3
          option forwardfor
          # nginx (the actual listener on 127.0.0.1:8080) has
          # keepalive_timeout 65s and will silently close an idle backend
          # socket after that. HAProxy's default mode is end-to-end
          # keep-alive, so without this it will happily try to reuse a
          # backend connection nginx already closed once a mobile client's
          # own (longer) keep-alive idle assumption outlives 65s - producing
          # exactly the "unexpected end of stream" / EOFException the
          # CalDAV/CardDAV client saw. Since the backend is localhost, the
          # cost of a fresh TCP connection per request is negligible, so
          # just don't try to reuse them here.
          option http-server-close
          #http-response replace-value Location http://localhost:${builtins.toString nextcloudPort}/(.*) https://next.thehellings.com/\2
          server nextcloud 127.0.0.1:${builtins.toString nextcloudPort}
      '';
    };

    immich-public-proxy = {
      enable = true;
      immichUrl = "http://immich.k3s.thehellings.lan";
      settings = {
        ipp = {
          allowDownload = 1;
        };
      };
    };

    logrotate = {
      enable = true;
      settings = {
        haproxy = {
          enable = true;
          files = "/var/log/haproxy.log";
          # rsyslogd (not haproxy) owns this file; signal it to reopen its
          # own fd after rotation, the same convention glibc-syslog
          # daemons use, rather than relying on copytruncate (which would
          # race a fail2ban tail mid-rotation).
          postrotate = "${pkgs.systemd}/bin/systemctl kill -s HUP syslog.service";
        };
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
      hostName = "127.0.0.1";
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
    nginx = {
      virtualHosts."${config.services.nextcloud.hostName}".listen = [
        {
          addr = "127.0.0.1";
          port = nextcloudPort;
        }
      ];

      # Route nginx access logs through syslog/journald (rather than only to
      # /var/log/nginx/access.log, which the read-only monitoring account
      # can't read) so `journalctl -t nginx_access` gives visibility into
      # Nextcloud request traffic during bandwidth investigations.
      #
      # NOTE: nginx's syslog "tag" only allows alphanumeric characters and
      # underscores (no hyphens) - an earlier version of this used
      # tag=nginx-access, which fails nginx's config test with:
      #   nginx: [emerg] syslog "tag" only allows alphanumeric characters
      #   and underscore in .../nginx.conf:114
      # That broke nginx.service (and, transitively, Nextcloud/next.thehellings.com,
      # which is proxied through nginx on 127.0.0.1:8080) until nginx hit its
      # systemd restart limit and gave up (start-limit-hit).
      appendHttpConfig = ''
        access_log syslog:server=unix:/dev/log,tag=nginx_access combined;
      '';
    };

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

  users.users.haproxy.extraGroups = [
    config.security.acme.certs."thehellings.com".group
    # Since #47e4f14, the `git` backend routes through the Anubis proxy over
    # a unix socket (mode 0770, owned by anubis:anubis) instead of talking
    # to the k3s backends directly. HAProxy was never granted membership in
    # that group, so every connection attempt to the socket fails with
    # EACCES, HAProxy logs it as backend `git/anubsis` returning `SC` (no
    # server contactable), and every request to src.thehellings.com gets a
    # 503 even though git.k3s.thehellings.lan and Anubis are both healthy.
    config.services.anubis.instances.git.group
  ];

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
