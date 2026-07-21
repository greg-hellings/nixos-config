{
  config,
  lib,
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
    networking.domain = "thehellings.lan";
    time.timeZone = "America/Chicago";

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
