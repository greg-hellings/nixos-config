{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  cfg = config.greg.kde;

in
with lib;
{
  options = {
    greg.kde.enable = mkEnableOption "Enable my default KDE setup";
  };

  config = mkIf cfg.enable {
    hardware = {
      bluetooth.enable = true;
    };
    # Sets up a basic KDE installation
    systemd.services.bluetooth.requiredBy = [ "multi-user.target" ];
    services = {
      libinput.enable = true;
      blueman.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    }
    // (optionalAttrs (builtins.hasAttr "plasma6" options.services.xserver.desktopManager) {
      desktopManager.plasma6.enable = true;
      displayManager = {
        defaultSession = "plasma";
        sddm.enable = true;
      };
    });

    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true; # Enables screen sharing in Wayland
    };

    environment.systemPackages = with pkgs; [
      kalendar
      korganizer
    ];
  };
}
