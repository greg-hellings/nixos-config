{
  config,
  lib,
  pkgs,
  top,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    top.nix-hardware.nixosModules.framework-11th-gen-intel
  ];

  age.secrets = {
    compose-attic.file = ../../secrets/compose/attic.env.age;
  };

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
    tailscale = {
      enable = true;
      tags = [ "mobile" ];
    };
    runner = {
      enable = true;
      qemu = true;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vpl-gpu-rt
      ];
    };
  };

  nix.settings = {
    extra-platforms = config.boot.binfmt.emulatedSystems;
    system-features = [ "gccarch-x86-64-v3" ];
  };

  networking = {
    hostName = "exodus";
    networkmanager.enable = lib.mkForce true;
  };

  programs = {
    adb.enable = true;
    steam = {
      enable = true;
      protontricks.enable = true;
    };
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

  users.users.greg.extraGroups = [
    "adbusers"
    "kvm"
    "podman"
  ];
}
