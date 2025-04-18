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
    tailscale.enable = true;
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
