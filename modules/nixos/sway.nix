{ config, pkgs, lib, ... }:

let
  cfg = config.greg.sway;

in
with lib; {
  options = {
    greg.sway.enable = mkEnableOption "Enable my default Gnome3 setup";
  };

  config = mkIf cfg.enable {
    services = {
      accounts-daemon.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        audio.enable = true;
        jack.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      xserver = {
        enable = true;
        displayManager.gdm = {
          enable = true;
          autoSuspend = false;
          banner = "Welcome to Greg's JUDE machine. Do I know you?";
          wayland = true;
        };
        xkb.layout = "us";
      };
    };

    programs.sway = {
      enable = true; # Will be enabled through home-manager
      wrapperFeatures.gtk = true;
    };
    security.pam.services.swaylock = { };
  };
}
