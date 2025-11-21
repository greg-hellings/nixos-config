# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  top,
  ...
}:
let
  wanInterface = "enp2s0";
  lanInterface = "enp1s0";
  lanIpAddress = "10.42.1.7";
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    top.btc.nixosModules.default
    ./bitcoin.nix
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
    nfs-utils
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
    nameservers = [ "10.42.1.5" ];
    defaultGateway = "10.42.1.1";
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
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
            isDefault = true;
            editable = false;
          }
        ];
      };
      settings = {
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
    prometheus = {
      enable = true;
      exporters.graphite.enable = true;
      globalConfig.scrape_interval = "10s";
      scrapeConfigs = [
        {
          job_name = "node stats";
          static_configs = [
            {
              targets = lib.flatten (
                lib.map
                  (n: [
                    "${n}.shire-zebra.ts.net:${toString config.services.prometheus.exporters.node.port}"
                    "${n}.shire-zebra.ts.net:${toString config.services.prometheus.exporters.systemd.port}"
                    "${n}.shire-zebra.ts.net:${toString config.services.prometheus.exporters.ping.port}"
                  ])
                  [
                    "hosea"
                    "isaiah"
                    "jeremiah"
                    "zeke"
                    "genesis"
                    "exodus"
                    "linode"
                    "vm-gitlab"
                  ]
              ) ++ [
                "hosea.shire-zebra.ts.net:${toString config.services.prometheus.exporters.graphite.port}"
                "genesis.shire-zebra.ts.net:${toString config.services.prometheus.exporters.kea.port}"
                "genesis.shire-zebra.ts.net:${toString config.services.prometheus.exporters.dnsmasq.port}"
              ];
            }
          ];
        }
      ];
    };
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
