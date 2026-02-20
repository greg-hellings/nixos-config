# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  metadata,
  pkgs,
  ...
}:
let
  wanInterface = "enp2s0";
  lanInterface = "enp1s0";
  lanIpAddress = metadata.hosts.${config.networking.hostName}.ip;
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/";
      };
    };
    extraModprobeConfig = "vboxdrv";
  };

  environment.systemPackages = with pkgs; [
    clinfo
    jellyfin-ffmpeg
    libva-utils
    mesa-demos
    radeontop
    vulkan-tools
  ];

  greg = {
    home = true;
    proxies = {
      "jellyfin.home".target = "http://localhost:8096/";
      "jellyfin.thehellings.lan".target = "http://localhost:8096/";
    };
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        #intel-media-sdk
        intel-compute-runtime
      ];
    };
  };

  networking = {
    hostName = "hosea";
    nameservers = [ metadata.infra.dns ];
    defaultGateway = metadata.infra.gw;
    interfaces = {
      "${wanInterface}".useDHCP = true;
      "${lanInterface}" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = lanIpAddress;
            prefixLength = 16;
          }
        ];
      };
    };
  };

  services = {
    albyhub = {
      enable = true;
      openFirewall = true;
      settings = {
        workDir = "/chain/alby";
      };
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    grafana = {
      enable = true;
      provision = {
        enable = true;
        dashboards.settings.providers = [
          {
            name = "Dashboards";
            disableDeletion = true;
            options = {
              path = "/etc/grafana-dashboards";
              foldersFromFilesStructure = true;
            };
          }
        ];
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "https://prometheus.shire-zebra.ts.net";
            isDefault = true;
            editable = false;
          }
        ];
      };
      settings = {
        security.secret_key = "123456789";
        server = {
          domain = "${config.networking.hostName}.shire-zebra.ts.net";
          enforce_domain = true;
          http_addr = "0.0.0.0";
          enable_gzip = true;
          http_port = 3001;
        };
        analytics.reporting_enabled = false;
      };
    };
    prometheus.exporters.graphite.enable = true;
    # Configure keymap
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  systemd.mounts =
    let
      nfs = name: {
        what = "nas1.shire-zebra.ts.net:/mnt/all/${name}";
        type = "nfs";
        name = "${name}.mount";
        where = "/${name}";
        requires = [ "tailscaled-autoconnect.service" ];
        after = [ "tailscaled-autoconnect.service" ];
        wantedBy = [ "multi-user.target" ];
        mountConfig.Options = "_netdev,noexec,ro,timeo=50,retrans=5,soft";
      };
    in
    [
      (nfs "music")
      (nfs "photos")
      (nfs "video")
    ];

  users.users = {
    greg.extraGroups = [ "vboxusers" ];

    jellyfin.extraGroups = [
      "video"
      "render"
    ];
  };
}
