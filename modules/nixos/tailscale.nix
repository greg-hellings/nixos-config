{ lib, config, ... }:

let
  cfg = config.greg.tailscale;
in
{
  options = {
    greg.tailscale.enable = lib.mkEnableOption "Enable Tailscale";
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
      useRoutingFeatures = "both";
    };
    systemd.services.tailscaled.partOf = [ "network-online.target" ];
  };
}
