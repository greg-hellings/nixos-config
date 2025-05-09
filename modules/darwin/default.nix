{ config, pkgs, ... }:
{
  imports = [ ../baseline.nix ];

  home-manager = {
    useGlobalPkgs = true;
    users."gregory.hellings" = import ../../home/home.nix;
    extraSpecialArgs = {
      gnome = false;
      gui = false;
      home = "/Users/gregory.hellings";
    };
  };

  fonts.packages = with pkgs; [
    dejavu_fonts
    hack-font
    nerdfonts
  ];

  nix = {
    gc.interval.Hour = 24;
    settings.auto-optimise-store = false; # Darwin bugs?
  };

  power.sleep = {
    allowSleepByPowerButton = true;
    computer = "never";
    display = 30;
  };

  programs = {
    zsh.enable = true;
    bash.enable = true;
  };

  services.nix-daemon.enable = true;

  system = {
    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
        ShowRemovableMediaOnDesktop = true;
        ShowStatusBar = true;
      };
      LaunchServices.LSQuarantine = false;
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = true;
      };
      screencapture = {
        include-date = true;
        location = "${config.home-manager.extraSpecialArgs.home}/Photos/Screeneries";
      };
      trackpad = {
        Dragging = false;
        TrackpadRightClick = true;
      };
    };
    startup.chime = false;
    stateVersion = 6;
  };

  time.timeZone = "America/Chicago";

  users.users."gregory.hellings".home = "/Users/gregory.hellings";
}
