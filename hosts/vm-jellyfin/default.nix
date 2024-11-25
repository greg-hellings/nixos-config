{ lib, ... }:

{
  boot.loader.grub.devices = [ "/dev/disk/by-label/ESP" ];

  greg = {
    proxies."jellyfin.home".target = "http://localhost:8096/";
    tailscale.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/music" = {
      device = "10.42.1.4:/volume1/music";
      fsType = "nfs";
      options = [ "ro" ];
    };
    "/photo" = {
      device = "10.42.1.4:/volume1/photo";
      fsType = "nfs";
      options = [ "ro" ];
    };
    "/video" = {
      device = "10.42.1.4:/volume1/video/";
      fsType = "nfs";
      options = [ "ro" ];
    };
  };

  networking = {
    hostName = "vm-jellyfin";
    domain = lib.mkForce null; # The proxmox generator fails at this, somehow
  };

  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    qemuGuest.enable = true;
  };

  virtualisation.diskSize = 20 * 1024;
}
