{
  config,
  lib,
  metadata,
  pkgs,
  top,
  ...
}:
{
  imports = [
    ../modules/nix-conf.nix
    top.niks3.nixosModules.niks3-auto-upload
  ];

  age.secrets.niks3-api-token.file = ../secrets/niks3/api_token.age;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    top.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3
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
    git
    gnupatch
    top.self.packages.${pkgs.stdenv.hostPlatform.system}.hms # My own home manager switcher
    iperf
    killall
    nano
    nfs-utils
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
    extraHosts =
      let
        onNetwork =
          attr: _k: v:
          (builtins.hasAttr attr v) && v.${attr} != null;
        getIPs =
          attr: domain:
          (lib.mapAttrsToList (host: v: "${builtins.getAttr attr v} ${host}.${domain}") (
            lib.filterAttrs (onNetwork attr) metadata.hosts
          ));
      in
      builtins.concatStringsSep "\n" (
        (getIPs "ts" "shire-zebra.ts.net")
        ++ (getIPs "nebulaIp" "nebula.thehellings.com")
        ++ (getIPs "nebulaIp" "nebula")
        ++ (getIPs "ip" "thehellings.lan")
      );
    search = [
      "nebula.thehellings.com"
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
    niks3-auto-upload = {
      enable = config.greg.nix.cache;
      authTokenFile = config.age.secrets.niks3-api-token.path;
      serverUrl = "http://hosea.nebula.thehellings.com:5751";
      verifyS3Integrity = true;
    };
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

  security = {
    sudo-rs = {
      enable = true;
      extraRules = [
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
    };
    sudo.enable = false;
  };

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
