# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    gawk
    git
    unzip
    wget
  ];

  fileSystems = {
    "/nix" = {
      fsType = "btrfs";
      options = [ "subvol=nix" ];
      device = "/dev/nvme0n1p1";
    };
    "/var" = {
      fsType = "btrfs";
      options = [ "subvol=var" ];
      device = "/dev/nvme0n1p1";
    };
  };

  greg = {
    home = true;
    tailscale.enable = true;
    remote-builder.enable = true;
  };

  networking = {
    hostName = "jeremiah"; # Define your hostname.
    useDHCP = false;
    defaultGateway = {
      address = " 10.42.1.2";
      interface = "enp68s0";
    };
    interfaces = {
      enp68s0 = {
        ipv4.addresses = [
          {
            address = "10.42.1.8";
            prefixLength = 16;
          }
        ];
      };
    };
    nameservers = [ "10.42.1.5" ];
  };

  #####################################################################################
  #################### Virtualbox Runner ##############################################
  #####################################################################################
  age.secrets.runner-reg.file = ../../secrets/gitlab/jeremiah-runner-reg.age;

  services = {
    gitlab-runner = {
      enable = true;
      settings.concurrent = 5;
      services = {
        shell = {
          executor = "shell";
          limit = 1;
          authenticationTokenConfigFile = config.age.secrets.runner-reg.path;
          environmentVariables = {
            EFI_DIR = "${pkgs.OVMF.fd}/FV/";
            STORAGE_URL = "s3.thehellings.lan:9000";
          };
        };
      };
    };
  };

  systemd.services."gitlab-runner" = {
    after = [
      "network.target"
      "network-online.target"
      "tailscaled.service"
    ];
    requires = [
      "network-online.target"
      "tailscaled.service"
    ];
    serviceConfig = {
      DevicePolicy = lib.mkForce "auto";
      User = "root";
      DynamicUser = lib.mkForce false;
    };
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
    enableHardening = false;
    headless = true;
    enableWebService = true;
  };
}
