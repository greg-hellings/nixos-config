{
  config,
  metadata,
  modulesPath,
  pkgs,
  ...
}:
let
  cfg = config.services.dendrite;
  # Dendrite runs with DynamicUser = true as user `dendrite`; peer auth over
  # the local socket maps that straight onto the `dendrite` Postgres role, so
  # no database password is needed.
  db = {
    connection_string = "postgres:///dendrite?host=/run/postgresql&sslmode=disable";
  };
in
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  environment.systemPackages = [
    pkgs.e2fsprogs
    pkgs.fdisk
    pkgs.parted
  ];

  # Migration of the Dendrite Matrix homeserver off Kubernetes
  # (manifests/matrix/ + the `matrix` database in manifests/databases/) onto
  # its own Proxmox VM. Settings translated from the dendrite.yaml template in
  # manifests/matrix/dendrite-config.yaml.
  #
  # Follow-up steps after the VM is created (not done in this PR):
  #   1. Add matrix's real `pubkey` (its /etc/ssh host ed25519 key) to
  #      network.json, then `agenix rekey` so the host can decrypt
  #      nebula/matrix.key.age, dendrite_key.age and matrix/dendrite.env.age.
  #   2. Confirm secrets/dendrite_key.age holds the same signing key as the
  #      Bitwarden note k8s mounts as matrix.pem (6de3500c-...). It MUST be
  #      the same key, or federation breaks for thehellings.com.
  #   3. Stop the k8s Deployment, `pg_dump -Fc` the `matrix` database from
  #      the CNPG `postgres` cluster (db namespace) and restore it here with
  #      `pg_restore --no-owner --role=dendrite -d dendrite`. Copy the media
  #      store and jetstream dir (/var/dendrite in the pod) into
  #      /var/lib/private/dendrite/{media,jetstream}.
  #   4. Repoint linode's haproxy `matrix` backend at matrix.thehellings.lan
  #      (Host header + health check) and drop manifests/matrix from
  #      manifests/kustomization.yaml.

  age.secrets = {
    # Signing key (passed in with LoadCredential, so root ownership is fine)
    dendrite-key.file = ../../../secrets/dendrite_key.age;
    # REGISTRATION_SHARED_SECRET=... for creating accounts with
    # `create-account` while open registration stays disabled.
    dendrite-env.file = ../../../secrets/matrix/dendrite.env.age;
  };

  greg = {
    home = true;
    nebula.enable = true;
    proxies =
      let
        tgt = {
          target = "http://127.0.0.1:${toString cfg.httpPort}";
          genAliases = false;
          extraConfig = ''
            client_max_body_size ${toString (cfg.settings.media_api.max_file_size_bytes / 1048576 + 1)}M;
          '';
        };
      in
      {
        "matrix.nebula.thehellings.com" = tgt;
        "matrix.thehellings.lan" = tgt;
      };
    # Nightly SQL dumps land under /var/backup/postgresql (picked up by the
    # restic job below); the media store and jetstream state are under
    # dendrite's StateDirectory.
    backup.jobs = {
      dendrite = {
        src = "/var/lib/private/dendrite";
        dest = "dendrite";
      };
      dendrite-db = {
        src = config.services.postgresqlBackup.location;
        dest = "database-matrix";
      };
    };
  };

  networking = {
    defaultGateway = metadata.infra.gw;
    nameservers = [ metadata.infra.dns ];
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = metadata.hosts."${config.networking.hostName}".ip;
          prefixLength = 16;
        }
      ];
    };
  };

  proxmox.cloudInit.enable = false;

  services = {
    fstrim.enable = true;

    dendrite = {
      enable = true;
      httpPort = 8008;
      environmentFile = config.age.secrets.dendrite-env.path;
      loadCredential = [ "private_key:${config.age.secrets.dendrite-key.path}" ];
      settings = {
        global = {
          server_name = "thehellings.com";
          key_id = "ed25519:auto";
          private_key = "$CREDENTIALS_DIRECTORY/private_key";
          database = db // {
            max_open_conns = 90;
            max_idle_conns = 2;
            conn_max_lifetime = -1;
          };
          well_known_server_name = "matrix.thehellings.com:443";
          well_known_client_name = "https://matrix.thehellings.com";
          disable_federation = false;
          presence = {
            enable_inbound = false;
            enable_outbound = false;
          };
          jetstream = {
            storage_path = "/var/lib/dendrite/jetstream";
            topic_prefix = "Dendrite";
          };
          server_notices = {
            enabled = true;
            local_part = "_server";
            display_name = "Server Alert";
            room_name = "Server Alert";
          };
          report_stats.enabled = false;
          cache = {
            max_size_estimated = "1gb";
            max_age = "1h";
          };
        };
        # The nixpkgs module defaults every component to its own SQLite
        # file, which would override global.database - point them all at
        # the shared Postgres database instead.
        app_service_api.database = db;
        federation_api = {
          database = db;
          send_max_retries = 16;
          key_perspectives = [
            {
              server_name = "matrix.org";
              keys = [
                {
                  key_id = "ed25519:auto";
                  public_key = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
                }
                {
                  key_id = "ed25519:a_RXGa";
                  public_key = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
                }
              ];
            }
          ];
          deny_networks = [
            "127.0.0.1/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10"
            "169.254.0.0/16"
            "::1/128"
            "fe80::/64"
            "fc00::/7"
          ];
          allow_networks = [ "0.0.0.0/0" ];
        };
        key_server.database = db;
        relay_api.database = db;
        media_api = {
          database = db;
          base_path = "/var/lib/dendrite/media";
          max_file_size_bytes = 10485760;
          dynamic_thumbnails = false;
          max_thumbnail_generators = 10;
          thumbnail_sizes = [
            {
              width = 32;
              height = 32;
              method = "crop";
            }
            {
              width = 96;
              height = 96;
              method = "crop";
            }
            {
              width = 640;
              height = 480;
              method = "scale";
            }
          ];
        };
        mscs.database = db;
        room_server = {
          database = db;
          default_room_version = "10";
        };
        sync_api = {
          database = db;
          search.enabled = false;
        };
        user_api = {
          account_database = db;
          device_database = db;
          bcrypt_cost = 10;
        };
        client_api = {
          registration_disabled = true;
          registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
          guests_disabled = false;
          rate_limiting = {
            enabled = true;
            threshold = 5;
            cooloff_ms = 500;
          };
        };
        logging = [
          {
            type = "std";
            level = "info";
          }
        ];
      };
    };

    openssh = {
      enable = true;
      openFirewall = true;
    };

    # Match the CNPG cluster's major version so the dump restores cleanly.
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
      ensureDatabases = [ "dendrite" ];
      ensureUsers = [
        {
          name = "dendrite";
          ensureDBOwnership = true;
        }
      ];
    };

    postgresqlBackup = {
      enable = true;
      databases = [ "dendrite" ];
    };
  };

  systemd.services.dendrite = {
    after = [ "postgresql.target" ];
    requires = [ "postgresql.target" ];
  };
}
