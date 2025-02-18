# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  dashy_port = "8080";
  speedtest_port = "19472";
  uptime_kuma_port = "4000";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./acme.nix
    ./hardware-configuration.nix
    ./home-assistant.nix
    ./networking.nix
  ];

  greg = {
    home = true;
    gnome.enable = false;
    proxies = {
      "speed.home".target = "http://localhost:${speedtest_port}";
      "speedtest.thehellings.lan".target = "http://localhost:${speedtest_port}";
      "dashy.home".target = "http://localhost:${dashy_port}";
      "uptime.home".target = "http://localhost:${uptime_kuma_port}";
    };
  };

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = true;
  };

  #boot.loader = {
  #	systemd-boot.enable = true;
  #	efi = {
  #		canTouchEfiVariables = true;
  #		efiSysMountPoint = "/boot/efi";
  #	};
  #};

  environment.systemPackages = with pkgs; [
    awscli2
    create_ssl
    step-ca
  ];

  networking.hostName = "genesis"; # Define your hostname.

  services = {
    dashy = {
      enable = true;
      settings = {
        appConfig = {
          enableFontAwesome = true;
          statusCheck = true;
          statusCheckInterval = 20;
          theme = "callisto";
        };
        pageInfo = {
          description = "Hellings Lab";
          navLinks = [
            {
              path = "/";
              title = "Home";
            }
            {
              path = "http://speed.home";
              title = "Local Speedtest";
            }
          ];
        };
        sections = [
          {
            name = "Hosting";
            displayData = {
              sortBy = "alphabetical";
              rows = 1;
              cols = 1;
              collapsed = false;
              hideForGusts = false;
            };
            items = [
              {
                title = "Romans";
                description = "Core Proxmox";
                icon = "favicon";
                url = "https://10.42.1.1:8006";
                target = "newtab";
                statusCheckAllowInsecure = true;
              }
              {
                title = "Isaiah";
                description = "Isaiah Proxmox";
                icon = "favicon";
                url = "https://isaiah.thehellings.lan:8006";
                target = "newtab";
                statusCheckAllowInsecure = true;
              }
              {
                title = "Linode";
                icon = "favicon";
                url = "https://login.linode.com/login";
                target = "newtab";
              }
            ];
          }
          {
            name = "Services";
            displayData = {
              sortBy = "alphabetical";
              rows = 1;
              cols = 1;
              collapsed = false;
              hideForGusts = false;
            };
            items = [
              {
                title = "Jellyfin";
                description = "Home Jellyfin Server";
                icon = "favicon";
                url = "http://jellyfin.home";
                target = "newtab";
              }
              {
                title = "Speedtest";
                description = "Local Speedtest";
                icon = "favicon";
                url = "http://speed.home";
                target = "newtab";
              }
            ];
          }
        ];
      };
    };
    uptime-kuma = {
      enable = true;
      settings = {
        PORT = uptime_kuma_port;
      };
    };
  };

  virtualisation.oci-containers.containers = {
    dashy = {
      image = "lissy93/dashy:latest";
      hostname = "dashy";
      ports = [ "${dashy_port}:${dashy_port}" ];
      volumes = [ "${config.services.dashy.finalDrv}/conf.yml:/app/user-data/conf.yml" ];
    };
    speedtest = {
      image = "ghcr.io/librespeed/speedtest";
      hostname = "speedtest";
      ports = [ "${speedtest_port}:80" ];
    };
  };
}
