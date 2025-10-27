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
    nfs-utils
    radeontop
    vulkan-tools
  ];

  systemd.mounts = let
    nfs = name: {
      what = "nas1.shire-zebra.ts.net:/mnt/all/${name}";
      type = "nfs";
      name = "${name}.mount";
      where = "/${name}";
      requires = [ "tailscaled-autoconnect.service" ];
      after = [ "tailscaled-autoconnect.service" ];
      wantedBy = [ "multi-user.target" ];
      mountConfig.Options = "_netdev,noexec,ro,timeo=50,retrans=5,soft";
    };
  in [
    (nfs "music")
    (nfs "photos")
    (nfs "video")
  ];

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
