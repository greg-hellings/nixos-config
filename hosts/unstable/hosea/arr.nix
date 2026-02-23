{
  lib,
  metadata,
  pkgs,
  ...
}:
let
  ips = lib.filterAttrs (_k: v: v ? "ip" && v.ip != null) metadata.hosts;
  tps = lib.filterAttrs (_k: v: v ? "ts" && v.ts != null) metadata.hosts;
  get = field: set: lib.mapAttrsToList (_k: v: v.${field}) set;
  getTS = get "ts" tps;
  getIP = get "ip" ips;
  whitelists = builtins.concatStringsSep "," (
    [
      "localhost"
      "127.0.0.1"
    ]
    ++ getTS
    ++ getIP
  );
in
{
  services = {
    radarr = {
      enable = true;
      openFirewall = true;
    };
    transmission = {
      enable = true;
      openPeerPorts = true;
      openRPCPort = true;
      package = pkgs.transmission_4;
      settings = {
        download-dir = "/arr/transmission/downloads";
        rpc-bind-address = "0.0.0.0";
        rpc-host-whitelist = whitelists;
        rpc-host-whitelist-enabled = false;
        rpc-whitelist = whitelists;
        rpc-whitelist-enabled = false;
        watch-dir-enabled = true;
        watch-dir = "/arr/transmission/incoming";
      };
    };
  };

  systemd.mounts =
    let
      nfs = name: {
        what = "nas1.shire-zebra.ts.net:/mnt/all/${name}";
        type = "nfs";
        name = "${name}.mount";
        where = "/${name}";
        requires = [ "tailscaled-autoconnect.service" ];
        after = [ "tailscaled-autoconnect.service" ];
        wantedBy = [ "multi-user.target" ];
        mountConfig.Options = "_netdev,noexec,timeo=50,retrans=5,soft";
      };
    in
    [
      (nfs "arr")
      (nfs "music")
      (nfs "photos")
      (nfs "video")
    ];
}
