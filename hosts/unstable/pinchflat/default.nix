{
  config,
  metadata,
  modulesPath,
  ...
}:
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  greg = {
    home = true;
    nebula.enable = true;
    nix.cache = false;
    proxies =
      let
        tgt = {
          target = "http://localhost:${toString config.services.pinchflat.port}";
          genAliases = false;
        };
      in
      {
        "pinchflat.nebula.thehellings.com" = tgt;
        "pinchflat.thehellings.lan" = tgt;
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
      what = "nas1.thehellings.lan:/mnt/all/video/yt";
      type = "nfs";
      name = "downloads.mount";
      where = "/downloads";
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
