{
  config,
  lib,
  metadata,
  top,
  ...
}:

{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    # ./virt.nix
    top.nix-hardware.nixosModules.system76
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  greg = {
    gitea-runner = {
      enable = true;
      extraLabels = [ "bare-metal:host" ];
    };
    kubernetes = {
      enable = true;
      vipInterface = "enp12s0";
      priority = 253;
    };
    nebula.enable = true;
    remote-builder.enable = true;
    runner = {
      enable = true;
      vbox = false;
    };
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      nvidiaSettings = true;
      open = true;
    };
    system76 = {
      firmware-daemon.enable = true;
      #kernel-modules.enable = true;
    };
  };

  networking = {
    hostName = "zeke";
    networkmanager.enable = lib.mkForce true;
    enableIPv6 = false;
    useDHCP = false;
    interfaces.enp12s0.useDHCP = true;
  };

  # Let's do a sound thing
  services = {
    k3s = {
      extraFlags = [
        "--tls-san ${metadata.hosts.${config.networking.hostName}.ip}"
        #"--bind-address ${ip}"
      ];
    };
  };

  users.users.greg.extraGroups = [
    "podman"
  ];

  # virtualisation.virtualbox.host = {
  #   enableExtensionPack = true;
  #   headless = true;
  #   enableWebService = true;
  # };
}
