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

    # Defensive rate-limit: cap any single misbehaving service's journal
    # output fleet-wide. Discovered live on kuma (uptime-kuma logging a
    # Prometheus-label validation error on every monitor beat, ~100k
    # lines/hour) that a runaway logger can itself become the obstacle to
    # incident investigation — journalctl becomes slow/unresponsive and
    # disk fills — on top of drowning out genuinely useful log signal.
    # This doesn't fix a specific app's bug, but bounds the blast radius.
    journald.extraConfig = ''
      RateLimitIntervalSec=30s
      RateLimitBurst=2000
    '';

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
