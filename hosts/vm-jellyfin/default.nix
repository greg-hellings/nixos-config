{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  greg = {
    home = true;
    proxies."jellyfin.home".target = "http://localhost:8096/";
    proxies."jellyfin.thehellings.lan".target = "http://localhost:8096/";
    tailscale = {
      enable = true;
      hostname = "jellyfin";
    };
  };

  environment.systemPackages = with pkgs; [
    clinfo
    glxinfo
    jellyfin-ffmpeg
    libva-utils
    radeontop
    vulkan-tools
  ];

  fileSystems = {
    "/music" = {
      device = "nas1.shire-zebra.ts.net:/mnt/all/music";
      fsType = "nfs";
      options = [ "ro" ];
    };
    "/photo" = {
      device = "nas1.shire-zebra.ts.net:/mnt/all/photos";
      fsType = "nfs";
      options = [ "ro" ];
    };
    "/video" = {
      device = "nas1.shire-zebra.ts.net:/mnt/all/video/";
      fsType = "nfs";
      options = [ "ro" ];
    };
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
    };
  };

  networking = {
    hostName = "vm-jellyfin";
    firewall.allowedTCPPorts = [ 80 ];
  };

  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    qemuGuest.enable = true;
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];
}
