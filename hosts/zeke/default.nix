{
  config,
  lib,
  top,
  ...
}:

{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./virt.nix
    top.nix-hardware.nixosModules.system76
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  greg = {
    kubernetes = {
      enable = true;
      vipInterface = "enp12s0";
      priority = 253;
    };
    remote-builder.enable = true;
    runner = {
      enable = true;
      vbox = true;
    };
    tailscale.enable = true;
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
    interfaces = {
      # This seems to be direct mother board interface
      enp12s0.useDHCP = true;
      enp12s0.ipv4.addresses = [
        {
          address = "10.42.1.13";
          prefixLength = 16;
        }
      ];
    };
    defaultGateway = {
      address = "10.42.1.1";
      interface = "enp12s0";
    };
    nameservers = [
      "10.42.1.5"
      "10.42.1.1"
    ];
  };

  # Let's do a sound thing
  services = {
    k3s = {
      extraFlags =
        let
          ip = (builtins.head config.networking.interfaces.enp12s0.ipv4.addresses).address;
        in
        [
          "--tls-san ${ip}"
          #"--bind-address ${ip}"
        ];
    };
    xserver.videoDrivers = [ "nvidia" ];
  };

  users.users.greg.extraGroups = [
    "kvm"
    "podman"
  ];

  virtualisation.virtualbox.host = {
    enableExtensionPack = true;
    headless = true;
    enableWebService = true;
  };
}
