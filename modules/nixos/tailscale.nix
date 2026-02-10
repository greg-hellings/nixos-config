{
  lib,
  config,
  ...
}:

let
  cfg = config.greg.tailscale;
  tags = lib.concatMapStringsSep "," (s: "tag:${s}") cfg.tags;
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
      tailscaled.partOf = [ "network-online.target" ];
    };
  };
}
