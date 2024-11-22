{ ... }:

{
  imports = [ ];
  #boot.loader.grub.devices = [ "/dev/vda" ];

  greg = {
    proxies."jellyfin.home".target = "http://localhost:8096/";
    tailscale.enable = true;
  };

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

  networking = {
    hostName = "vm-jellyfin";
    domain = "thehellings.lan";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
