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
    # ./virt.nix
    top.nix-hardware.nixosModules.system76
    top.buildbot.nixosModules.buildbot-worker
  ];

  age.secrets = {
    gitea-workerPassword.file = ../../secrets/gitea/workerPassword.age;
  };

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
    buildbot-nix.worker = {
      enable = true;
      masterUrl = "tcp:host=jeremiah.shire-zebra.ts.net:port=9989";
      name = "zeke";
      workerPasswordFile = config.age.secrets.gitea-workerPassword.path;
    };
    k3s = {
      extraFlags = [
        "--tls-san 10.42.1.13"
        #"--bind-address ${ip}"
      ];
    };
    xserver.videoDrivers = [ "nvidia" ];
  };

  users.users.greg.extraGroups = [
    "podman"
  ];

  virtualisation.virtualbox.host = {
    enableExtensionPack = true;
    headless = true;
    enableWebService = true;
  };
}
