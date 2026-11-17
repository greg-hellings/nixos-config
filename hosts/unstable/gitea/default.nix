{
  config,
  metadata,
  modulesPath,
  pkgs,
  ...
}:
let
  cfg = config.services.gitea;
  sshPort = 2222;
in
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  environment.systemPackages = [
    pkgs.e2fsprogs
    pkgs.parted
    pkgs.unixtools.fdisk
  ];

  # Migration of Gitea off Kubernetes (manifests/gitea/) onto its own Proxmox
  # VM. Translated from the Helm values in manifests/gitea/chart.yaml:
  #   - CNPG `postgres` cluster (db/user `gitea`) -> local PostgreSQL over the
  #     unix socket (peer auth, so no DB password secret is needed)
  #   - MinIO/garage object storage on nas1 -> unchanged, same bucket, so
  #     attachments/LFS/avatars/packages do not need to be moved
  #   - `gitea-new` PVC (repositories + data) -> /var/lib/gitea
  #   - gitea-dump CronJob -> services.gitea.dump + restic (greg.backup)
  #   - admin `greg` w/ initialOnlyRequireReset -> gitea-admin-init below
  #
  # Follow-up steps after the VM is created (not done in this PR):
  #   1. Add gitea's real `pubkey` (its /etc/ssh host ed25519 key) to
  #      network.json, then `agenix rekey` so the host can decrypt
  #      nebula/gitea.key.age and the gitea/* secrets referenced below.
  #   2. Put the real nas1 MinIO credentials (Bitwarden item 33e8e4e0-...,
  #      currently consumed by the k8s `gitea-config` ExternalSecret) into
  #      secrets/gitea/minioAccessKeyId.age and minioSecretAccessKey.age -
  #      they are committed with placeholder contents.
  #   3. Stop the k8s release, restore the CNPG `gitea` database into the
  #      local PostgreSQL (`pg_dump -Fc` from the cluster, then
  #      `pg_restore --no-owner --role=gitea -d gitea`), and rsync the
  #      `gitea-new` PVC's repositories into /var/lib/gitea/repositories.
  #      The nixpkgs gitea package must be >= the version that last migrated
  #      the database in k8s.
  #   4. Repoint linode's Anubis `git` TARGET / haproxy SSH backend and the
  #      jeremiah buildbot/runner URLs at this host, then drop
  #      manifests/gitea from manifests/kustomization.yaml.

  age.secrets = {
    gitea-admin-password = {
      file = ../../../secrets/gitea/adminPassword.age;
      owner = cfg.user;
    };
    gitea-minio-access-key-id = {
      file = ../../../secrets/gitea/minioAccessKeyId.age;
      owner = cfg.user;
    };
    gitea-minio-secret-access-key = {
      file = ../../../secrets/gitea/minioSecretAccessKey.age;
      owner = cfg.user;
    };
  };

  greg = {
    home = true;
    nebula.enable = true;
    proxies =
      let
        tgt = {
          target = "http://127.0.0.1:${toString cfg.settings.server.HTTP_PORT}";
          genAliases = false;
          # Large pushes / LFS / package uploads
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
      in
      {
        "gitea.nebula.thehellings.com" = tgt;
        "gitea.thehellings.lan" = tgt;
      };
    # `gitea dump` includes the database, repositories and the object
    # storage contents, so backing up the dump directory is sufficient.
    backup.jobs.gitea = {
      src = cfg.dump.backupDir;
      dest = "gitea";
    };
  };

  networking = {
    defaultGateway = metadata.infra.gw;
    nameservers = [ metadata.infra.dns ];
    firewall.allowedTCPPorts = [
      cfg.settings.server.HTTP_PORT
      sshPort
    ];
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

    gitea = {
      enable = true;
      appName = "Gitea: Greg's Cup of Git";
      database.type = "postgres"; # createDatabase defaults to true -> local socket
      dump = {
        enable = true;
        interval = "03:00";
        type = "tar.zst";
      };
      lfs.enable = true;
      minioAccessKeyId = config.age.secrets.gitea-minio-access-key-id.path;
      minioSecretAccessKey = config.age.secrets.gitea-minio-secret-access-key.path;
      # Reference: https://docs.gitea.com/administration/config-cheat-sheet
      settings = {
        server = {
          ROOT_URL = "https://src.thehellings.com/";
          HTTP_ADDR = metadata.hosts.gitea.nebulaIp;
          HTTP_PORT = 3000;
          # Built-in SSH server so the system sshd stays on 22 for admin
          # access. linode's haproxy forwards src.thehellings.com:2222 here.
          START_SSH_SERVER = true;
          SSH_DOMAIN = "src.thehellings.com";
          SSH_PORT = sshPort;
          SSH_LISTEN_PORT = sshPort;
        };
        session.PROVIDER = "db";
        queue.TYPE = "level";
        repository.ENABLE_PUSH_CREATE_USER = true;
        service.DISABLE_REGISTRATION = true;
        storage = {
          STORAGE_TYPE = "minio";
          MINIO_ENDPOINT = "nas1.thehellings.lan:30188";
          MINIO_BUCKET = "gitea";
          MINIO_LOCATION = "garage";
          MINIO_USE_SSL = false;
          MINIO_INSECURE_SKIP_VERIFY = true;
        };
        security = {
          ALLOWED_HOST_LIST = "loopback,private,*.shire-zebra.ts.net,*.nebula.thehellings.com,*.thehellings.lan";
          EGRESS_MODE = "lax";
        };
      };
    };

    openssh = {
      enable = true;
      openFirewall = true;
    };

    # Newer than or equal to the CNPG cluster's major so the dump restores.
    postgresql.package = pkgs.postgresql_18;
  };

  # Equivalent of the Helm chart's `gitea.admin` block with
  # passwordMode = initialOnlyRequireReset: create `greg` once with the
  # agenix-provided password and force a reset on first login. Does nothing
  # if the user already exists (e.g. after restoring the k8s database).
  systemd.services.gitea-admin-init = {
    description = "Create initial Gitea admin user";
    after = [ "gitea.service" ];
    requires = [ "gitea.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      cfg.package
      pkgs.gawk
      pkgs.gnugrep
    ];
    environment = {
      GITEA_WORK_DIR = cfg.stateDir;
      GITEA_CUSTOM = cfg.customDir;
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = cfg.user;
      Group = cfg.group;
      WorkingDirectory = cfg.stateDir;
    };
    script = ''
      if gitea admin user list --admin | awk 'NR > 1 { print $2 }' | grep -qx greg; then
        echo "Admin user greg already exists"
        exit 0
      fi
      gitea admin user create \
        --admin \
        --username greg \
        --email greg.hellings@gmail.com \
        --password "$(cat ${config.age.secrets.gitea-admin-password.path})" \
        --must-change-password
    '';
  };
}
