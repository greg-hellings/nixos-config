{
  pkgs,
  pkgs',
  top,
  ...
}:
let
  system = builtins.replaceStrings [ "darwin" ] [ "linux" ] pkgs.stdenv.hostPlatform.system;
  builderConfig = top.nixunstable.lib.nixosSystem {
    inherit system;
    modules = [
      "${top.nixunstable}/nixos/modules/profiles/nix-builder-vm.nix"
      {
        virtualisation = {
          host.pkgs = pkgs;
          darwin-builder = {
            workingDirectory = "/var/lib/darwin-builder";
            hostPort = 22;
          };
        };
      }
    ];
  };
  builder = {
    command = "${builderConfig.config.system.build.macos-builder-installer}/bin/create-builder";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/builder-vm-${system}.log";
      StandardErrorPath = "/var/log/builder-vm-${system}.stderr.log";
    };
  };
in
{
  environment = {
    launchDaemons = {
      "limit.maxfiles.plist" = {
        enable = true;
        text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>Label</key>
            <string>limit.maxfiles</string>
            <key>ProgramArguments</key>
            <array>
              <string>launchctl</string>
              <string>limit</string>
              <string>maxfiles</string>
              <string>524288</string>
              <string>524288</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
          </dict>
        </plist>
        '';
      };
    };
    systemPackages = with pkgs; [
      agenix
      pkgs'.hms
      procps  # Includes tools like `watch`, `kill`, and `ps`
    ];
  };

  fonts.packages = with pkgs; [
    dejavu_fonts
    nerd-fonts.hack
  ];

  #launchd.daemons.darwin-builder = builder;

  nix = {
    #buildMachines = [ { systems = ["aarch64-linux"]; sshUser = "builder"; sshKey = "/etc/nix/builder_ed25519"; hostName = "localhost:31022"; protocol = "ssh-ng"; }];
    enable = true;
    gc.interval.Hour = 3;
    #linux-builder.enable = true;
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
