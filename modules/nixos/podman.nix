{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.greg.podman;
in
{
  options.greg.podman.enable = lib.mkEnableOption "Enable podman in NixOS with my updates";

  config.virtualisation.podman = lib.mkIf cfg.enable {
    enable = true;
    dockerCompat = true;
    extraPackages = [
      pkgs.podman-compose
    ];
  };
}
