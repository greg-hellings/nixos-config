{
  config,
  lib,
  top,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    top.nix-hardware.nixosModules.framework-11th-gen-intel
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = [
      "i686-linux"
      "aarch64-linux"
    ];
  };

  greg = {
    home = true;
    gnome.enable = true;
    podman.enable = true;
    print.enable = true;
    tailscale.enable = true;
    vmdev = {
      enable = true;
      system = "intel";
    };
  };

  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  networking = {
    hostName = "exodus";
    networkmanager.enable = lib.mkForce true;
  };

  services = {
    fprintd.enable = true;
    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };
  };

  virtualisation = {
    oci-containers.backend = "podman";
  };

  users.users.greg.extraGroups = [ "podman" ];
}
