{
  lib,
  pkgs,
  top,
  ...
}:
let
  builder-config = {
    darwin-aarch-builder = top.self.nixosConfigurations.builder-aarch;
    darwin-x86-builder = top.self.nixosConfigurations.builder-x86;
  };
  builder = arch: let
    b = builder-config."darwin-${arch}-builder";
  in {
    command = "${b.config.system.build.macos-builder-installer}/bin/create-builder";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/builder-vm-${arch}.log";
      StandardErrorPath = "/var/log/builder-vm-${arch}.stderr.log";
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    hms
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    nerd-fonts.hack
  ];

  launchd.daemons = lib.genAttrs' [ "x86" "aarch" ] (arch: lib.nameValuePair "builder-${arch}-machine" (builder arch));

  nix = {
    enable = true;
    buildMachines = [
      {
        hostName = "ssh-ng://builder@localhost";
        system = "aarch64-linux";
        maxJobs = 4;
        supportedFeatures = [
          "kvm"
          "benchmarch"
          "big-parallel"
        ];
      }
    ];
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
