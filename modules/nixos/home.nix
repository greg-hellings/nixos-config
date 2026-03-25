{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.greg.home;

in
with lib;
{
  options.greg.home = mkOption {
    type = types.bool;
    default = true;
    description = "Sets the device up to be part of my home network";
  };

  config = mkIf cfg {
    age.secrets.attic.file = ../../secrets/attic.age;
    networking.domain = "thehellings.lan";
    time.timeZone = "America/Chicago";

    systemd.services.attic-client = {
      enable = true;
      description = "Attic client watch-store service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      preStart = ''
        set -x
        mkdir -p $XDG_CONFIG_HOME/attic
        cp ${config.age.secrets.attic.path} $XDG_CONFIG_HOME/attic/config.toml
      '';
      script = "${pkgs.attic-client}/bin/attic watch-store --ignore-upstream-cache-filter default";
      environment = {
        XDG_CONFIG_HOME = "/var/lib/attic-client";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/attic-client 0755 root root -"
    ];

    # Open Prometheus exporter ports on LAN-connected hosts only.
    # NOT in baseline.nix to avoid exposing these on internet-facing hosts (e.g. linode).
    networking.firewall.allowedTCPPorts = [
      9100 # prometheus node exporter
      9115 # prometheus blackbox exporter
      9427 # prometheus ping exporter
      9558 # prometheus systemd exporter
    ];
  };
}
