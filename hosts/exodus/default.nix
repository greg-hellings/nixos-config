{ config, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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

  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
}
