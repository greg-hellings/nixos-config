{
  config,
  metadata,
  modulesPath,
  ...
}:
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  # Migration of Pinchflat (https://github.com/kieraneglin/pinchflat) off
  # Kubernetes (manifests/pinchflat/) and onto its own Proxmox VM, modeled on
  # the kuma/money base host configs (proxmox-image, nebula, greg.home,
  # greg.proxies) plus hosea's NFS-over-Tailscale pattern, since — like the
  # k8s Deployment — this host needs to reach nas1's video share.
  #
  # Source of truth this was translated from: manifests/pinchflat/
  #   deployment.yaml - ghcr.io/kieraneglin/pinchflat container, port 8945,
  #     TZ=America/New_York, /downloads (NFS: nas1.shire-zebra.ts.net:/mnt/all/video/yt),
  #     /config (5Gi PVC)
  #   service.yaml / ingress.yaml - ClusterIP + tailscale ingress class, no
  #     auth in front of it
  #   pvc.yaml - pinchflat-config, 5Gi RWO
  #
  # nixpkgs ships a native `services.pinchflat` module (see
  # nixos/modules/services/misc/pinchflat.nix) so we use that directly rather
  # than an oci-container translation of the Deployment.
  #
  # IMPORTANT - deferred per Greg's direction: this PR only scaffolds the
  # host. It does NOT migrate the existing SQLite database / downloaded
  # video library out of the Kubernetes PVC. After this host is built and
  # deployed:
  #   1. Add pinchflat's real `pubkey` (its /etc/ssh host ed25519 key) to
  #      network.json, same as every other host.
  #   2. Sign a Nebula host cert/key for it with the (offline) CA key per
  #      secrets/nebula/README.md, `agenix -e secrets/nebula/pinchflat.key.age`,
  #      add `"nebula/pinchflat.key.age".publicKeys = everyone;` to
  #      secrets/secrets.nix, `agenix rekey`, then flip `greg.nebula.enable`
  #      below to `true` and add "pinchflat.nebula.thehellings.com" back to
  #      greg.proxies. NOT done in this PR: the agent authoring this host
  #      does not have access to the offline Nebula CA private key, so
  #      referencing a not-yet-existing `nebula/pinchflat.key.age` here
  #      would break `nix flake check`/eval for the whole flake (the path
  #      literal has to resolve at eval time) — same class of failure
  #      documented for brand-new hosts in the nixos-homelab-audit skill.
  #   3. Copy the Kubernetes `pinchflat-config` PVC contents (SQLite DB +
  #      metadata under /config) into this host's /var/lib/pinchflat, then
  #      cut the manifests/pinchflat/ Kustomization out of
  #      manifests/kustomization.yaml and decommission the k8s workload.
  #      The video library under /downloads is the same NFS share either
  #      way, so no data migration is needed for it.

  greg = {
    home = true;
    # See step 2 above - intentionally left disabled until a real cert/key
    # is signed with the offline CA key.
    nebula.enable = false;
    # Needed to reach nas1's Tailscale IP for the /downloads NFS mount
    # below - same pattern as hosea's NFS mounts. Uses the same
    # already-committed tailscale.age auth key as every other host, so
    # this part works out of the box (unlike Nebula, above).
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
    proxies =
      let
        tgt = {
          target = "http://localhost:${toString config.services.pinchflat.port}";
          genAliases = false;
        };
      in
      {
        "pinchflat.thehellings.lan" = tgt;
        "pinchflat.shire-zebra.ts.net" = tgt;
      };

    # /var/lib/pinchflat holds the SQLite DB + metadata/extras (the
    # equivalent of the k8s pinchflat-config PVC). The bulk video library
    # under /downloads is NFS-backed and intentionally excluded here, same
    # as wealthfolio/albyhub's SQLite-safety pattern elsewhere in this repo.
    backup.jobs.pinchflat = {
      src = "/var/lib/pinchflat";
      dest = "pinchflat";
      pre = "systemctl stop pinchflat || true";
      post = "systemctl start pinchflat";
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

    openssh = {
      enable = true;
      openFirewall = true;
    };

    pinchflat = {
      enable = true;
      # No BASIC_AUTH/SECRET_KEY_BASE in the original k8s Deployment either
      # (plain ClusterIP + tailscale Ingress, no auth) - `selfhosted` mirrors
      # that rather than introducing a new secretsFile requirement. Switch
      # to a proper `secretsFile` (see the nixpkgs module docs) if auth is
      # ever wanted in front of it.
      selfhosted = true;
      # mediaDir defaults under /var/lib/pinchflat; point it at the NFS
      # mount below instead, matching the Deployment's separate /downloads
      # volume.
      mediaDir = "/downloads";
      extraConfig = {
        # The Deployment set this explicitly (distinct from the host
        # default `time.timeZone` of America/Chicago set by greg.home) -
        # preserved here since extraConfig entries are appended after the
        # module's own TZ= derived from config.time.timeZone, so this wins.
        TZ = "America/New_York";
      };
    };
  };

  systemd.mounts = [
    {
      what = "nas1.shire-zebra.ts.net:/mnt/all/video/yt";
      type = "nfs";
      name = "downloads.mount";
      where = "/downloads";
      requires = [ "tailscaled-autoconnect.service" ];
      after = [ "tailscaled-autoconnect.service" ];
      wantedBy = [ "multi-user.target" ];
      mountConfig.Options = "_netdev,noexec,timeo=50,retrans=5,soft";
    }
  ];

  # Make sure the NFS-backed media directory is actually mounted before
  # pinchflat starts (it reads/writes MEDIA_PATH=/downloads at startup).
  systemd.services.pinchflat = {
    requires = [ "downloads.mount" ];
    after = [ "downloads.mount" ];
  };
}
