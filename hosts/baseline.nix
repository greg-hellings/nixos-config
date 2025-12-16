{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  builderHosts =
    if self != null then
      (lib.attrNames (
        lib.filterAttrs (_: v: v.config.greg.remote-builder.enable) self.nixosConfigurations
      ))
    else
      [ ];
in
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
      extraConfig = builtins.concatStringsSep "\n" (
        lib.map (x: ''
          Host ${x}-builder
            Hostname ${x}.home
            User remote-builder-user
        '') builderHosts
      );

      knownHosts = {
        chronicles = {
          extraHostNames = [
            "chronicles.thehellings.lan"
            "chronicles.home"
            "nas"
            "nas.thehellings.lan"
            "nas.home"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBecZUva9OnZuXLaBun6/1ITo5f9p0YMLPD+q0egLRS";
        };
        dns = {
          extraHostNames = [
            "dns"
            "dns.me.ts"
            "dns.home"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRCXdhXWHEvw84V9JC5bAGovvj12DLVphcEnsTHDjxW";
        };
        "genesis" = {
          extraHostNames = [
            "genesis.shire-zebra.ts.net"
            "genesis.home"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI9jbTPmEWQ0F2bLYmnIOLmBnag1fkKxHRjz3X8lB/k";
        };
        "git" = {
          extraHostNames = [
            "git.home"
            "git.thehellings.lan"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7hesFWwlmSbWPJWUiF8fIppy5a83yXw84O0Ytz+Zyq";
        };
        hosea = {
          extraHostNames = [
            "hosea.home"
            "hosea.thehellings.lan"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLIwkTTXA56sUlUjEulXXZRvZy5H4a5ZwgKWLlpkQDz";
        };
        isaiah = {
          extraHostNames = [
            "isaiah.home"
            "isaiah.thehellings.lan"
            "isaiah-builder"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHleYKtfV4W1Z63Ysu9w5Rbglqlz4F92YcZoMkucoTNf";
        };
        jeremiah = {
          extraHostNames = [
            "jeremiah.home"
            "jeremiah.thehellings.lan"
            "jeremiah-builder"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjQjXq9WYU2Ki27BR9WwJ4ZruS/lJXbjC1b0Q42Adi0";
        };
        zeke = {
          extraHostNames = [
            "zeke.home"
            "zeke.thehellings.lan"
            "zeke-builder"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0";
        };
        linode = {
          extraHostNames = [
            "linode.home"
            "linode.thehellings.lan"
            "thehellings.com"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9Zud3kZOl86gtmkn+uj3D4kiXWDPtyUL02VVLNR4Q";
        };
      };
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
