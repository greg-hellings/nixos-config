{
  config,
  lib,
  metadata,
  pkgs,
  ...
}:
{
  imports = [
    ../modules/nix-conf.nix
  ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    agenix
    bitwarden-cli
    bmon
    btop
    btrfs-progs
    coreutils-full
    diffutils
    efibootmgr
    findutils
    file
    gcc-tune
    git
    gnupatch
    hms # My own home manager switcher
    iperf
    killall
    nano
    lshw
    pciutils
    psmisc
    pwgen
    unzip
    usbutils
    wget
    xfsprogs
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    gc.dates = "weekly";
    settings.auto-optimise-store = true;
  };

  # Network Manager pulls in too many deps
  networking = {
    search = [
      "thehellings.lan"
      "home"
    ];
    networkmanager.enable = false;
  };

  programs = {
    gnupg.agent.enable = true;

    xonsh = {
      enable = true;
    };

    ssh = {
      knownHosts = builtins.mapAttrs (n: v: {
        extraHostNames = [
          "${n}.thehellings.lan"
          "${n}.shire-zebra.ts.net"
        ];
        publicKey = v.pubkey;
      }) (lib.filterAttrs (_: v: v ? "pubkey") metadata.hosts);
    };
  };

  # Enable the OpenSSH daemon for remote control
  services = {
    locate.enable = true;
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
    };
    prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "ethtool"
          "logind"
          "mountstats"
          "systemd"
          "tcpstat"
        ];
      };
      ping = {
        enable = true;
        settings = {
          ping = {
            interval = "10s";
            timeout = "5s";
          };
          targets = [
            "thehellings.com"
            "genesis.shire-zebra.ts.net"
            "www.google.com"
          ];
        };
      };
      systemd.enable = true;
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "greg" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.greg = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "wheel"
    ]; # Enable ‘sudo’ for the user.
    shell = config.programs.xonsh.package;
    initialPassword = "password";
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
      builtins.readFile ../home/ssh/authorized_keys
    );
  };

  system.stateVersion = "24.11";
}
