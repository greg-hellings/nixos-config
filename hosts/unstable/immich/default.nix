{
  config,
  metadata,
  modulesPath,
  pkgs,
  ...
}:
let
  cfg = config.services.immich;
in
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  environment.systemPackages = [
    pkgs.fdisk
    pkgs.e2fsprogs
  ];

  # Migration of Immich off Kubernetes (manifests/immich/) onto its own
  # Proxmox VM. Translated from manifests/immich/{chart,database,pvc}.yaml:
  #   - CNPG `immich` cluster (cloudnative-vectorchord:18) -> local
  #     PostgreSQL 18 with vectorchord, managed by services.immich.database
  #     over the unix socket (peer auth, so no DB password secret is needed)
  #   - `immich-storage` PVC (500Gi Longhorn) -> services.immich.mediaLocation
  #   - bundled valkey -> services.immich.redis (local redis)
  #   - machine-learning container -> services.immich.machine-learning
  #
  # Follow-up steps after the VM is created (not done in this PR):
  #   1. Size the VM disk for the library (the PVC is 500Gi) or attach a
  #      dedicated data disk and mount it at /var/lib/immich.
  #   2. Add immich's real `pubkey` (its /etc/ssh host ed25519 key) to
  #      network.json, then `agenix rekey` so the host can decrypt
  #      nebula/immich.key.age.
  #   3. Stop the k8s release, `pg_dump` the CNPG `immich` database and
  #      restore it here (see
  #      https://docs.immich.app/administration/backup-and-restore), then
  #      rsync the PVC's library into /var/lib/immich (owned by immich:immich).
  #      The nixpkgs immich package must be >= v3.2.4 (the k8s image tag).
  #   4. Repoint linode's services.immich-public-proxy.immichUrl at
  #      http://immich.thehellings.lan and drop manifests/immich from
  #      manifests/kustomization.yaml.

  greg = {
    home = true;
    nebula.enable = true;
    proxies =
      let
        tgt = {
          target = "http://127.0.0.1:${toString cfg.port}";
          genAliases = false;
          # Same intent as the traefik buffering annotation in k8s: allow
          # very large uploads (videos) and don't buffer them in nginx.
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_request_buffering off;
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
          '';
        };
      in
      {
        "immich.nebula.thehellings.com" = tgt;
        "immich.thehellings.lan" = tgt;
      };
    # Library (originals, thumbs, encoded video) plus Immich's own nightly
    # database dumps, which it writes to <mediaLocation>/backups.
    backup.jobs.immich = {
      src = cfg.mediaLocation;
      dest = "immich";
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

    immich = {
      enable = true;
      host = "127.0.0.1";
      port = 2283;
      # database.enable/createDB and redis.enable default to true: local
      # PostgreSQL (with vectorchord) and redis over unix sockets.
      machine-learning.enable = true;
      # settings left null on purpose: the system config lives in the
      # database restored from k8s and stays editable in the web UI.
    };

    openssh = {
      enable = true;
      openFirewall = true;
    };

    # Match the CNPG cluster's major version so the dump restores cleanly.
    postgresql.package = pkgs.postgresql_18;
  };
}
