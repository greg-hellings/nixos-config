{
  config,
  pkgs,
  ...
}:
{
  fonts.packages = with pkgs; [
    dejavu_fonts
    nerd-fonts.hack
  ];

  nix = {
    enable = true;
    gc.interval.Hour = 3;
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

  system = {
    defaults = {
      CustomSystemPreferences = {
        ".GlobalPreferences" = {
          "com.apple.swipescrolldirection" = 0;
        };
      };
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
        ShowDate = 2;
      };
      screencapture = {
        include-date = true;
        location = "~/Photos/Screeneries";
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
}
