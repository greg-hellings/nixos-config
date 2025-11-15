# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  top,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    top.proxmox.nixosModules.proxmox-ve
  ];

  # Bootloader.
  boot = {
    initrd.kernelModules = [
      "amdgpu"
    ];
    kernelParams = [
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
    clinfo
    curl
    gawk
    git
    mesa-demos
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
    "/var/pve" = {
      fsType = "btrfs";
      options = [ "subvol=pve" ];
      device = "/dev/nvme0n1p1";
    };
    "/btrfs" = {
      fsType = "btrfs";
      device = "/dev/nvme0n1p1";
    };
    "/media/proxmox" = {
      device = "10.42.1.4:/volume1/proxmox";
      fsType = "nfs";
      options = [ "noatime" ];
    };
  };

  greg = {
    home = true;
    kubernetes = {
      enable = true;
      vipInterface = "br0";
      priority = 254;
    };
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
    remote-builder.enable = true;
    runner = {
      enable = true;
      threads = 3;
      qemu = true;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking = {
    hostName = "jeremiah"; # Define your hostname.
    useDHCP = false;
    bridges.br0 = {
      interfaces = [ "enp68s0" ];
    };
    defaultGateway = {
      address = " 10.42.1.2";
      interface = "br0";
    };
    firewall.allowedTCPPorts = [ 3389 ];
    interfaces = {
      br0 = {
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

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };
  #####################################################################################
  #################### Virtualbox Runner ##############################################
  #####################################################################################
  age.secrets.runner-reg.file = ../../secrets/gitlab/nixos-qemu-shell.age;

  services = {
    displayManager = {
      defaultSession = "xfce";
      autoLogin = {
        enable = true;
        user = "greg";
      };
    };
    proxmox-ve = {
      enable = true;
      ipAddress = (builtins.elemAt config.networking.interfaces.br0.ipv4.addresses 0).address;
    };
    sunshine = {
      enable = true;
      autoStart = true;
      #capSysAdmin = true;
      openFirewall = true;
    };
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = true;
        xfce.enable = true;
      };
    };
  };

  systemd = {
    services = {
      "gitlab-runner" = {
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
    };
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  users.extraGroups.video.members = [ "greg" ];
}
