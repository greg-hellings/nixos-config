{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.greg.tailscale;
  tags = lib.concatMapStringsSep "," (s: "tag:${s}") cfg.tags;
  setScript = pkgs.writeShellApplication {
    name = "tailscale-set";
    runtimeInputs = [
      config.services.tailscale.package
    ];
    text = ''
      tailscale set --accept-routes
      tailscale set --hostname ${cfg.hostname}
    ''
    + lib.optionalString ((builtins.length cfg.tags) > 0) "tailscale set --advertise-tags ${tags}";
  };
in
{
  options = {
    greg.tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale";

      hostname = lib.mkOption {
        description = "Name on the tailnet to use";
        default = config.networking.hostName;
        type = lib.types.str;
      };

      tags = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [ ];
        description = "The tags to request for this node";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.tailscale-key.file = ../../secrets/tailscale.age;
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };
    environment.systemPackages = [ config.services.tailscale.package ];
    networking.firewall.checkReversePath = "loose";
    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale-key.path;
      authKeyParameters.preauthorized = true;
      extraUpFlags = lib.optionals ((builtins.length cfg.tags) > 0) [
        "--advertise-tags"
        tags
      ];
      useRoutingFeatures = "both";
    };
    systemd.services = {
      tailscale-set = {
        enable = true;
        after = [
          "tailscaled.service"
          "tailscale-autoconnect.service"
        ];
        partOf = [ "network-online.target" ];
        script = lib.getExe setScript;
      };
      tailscaled.partOf = [ "network-online.target" ];
    };
  };
}
