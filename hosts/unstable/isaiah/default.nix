{
  config,
  lib,
  metadata,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    extraModprobeConfig = "options kvm_amd nested=1";
    kernel.sysctl = {
      "net.bridge.bridge-nf-call-ip6tables" = 0;
      "net.bridge.bridge-nf-call-iptables" = 0;
      "net.bridge.bridge-nf-call-arptables" = 0;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };

  greg = {
    kubernetes = {
      enable = true;
      vipInterface = "enp38s0";
      vip = metadata.hosts.${config.networking.hostName}.ip;
      priority = 255;
    };
    nebula.enable = true;
    podman.enable = true;
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
    remote-builder.enable = true;
    runner = {
      enable = true;
      qemu = true;
    };
    gitea-runner = {
      enable = true;
      extraLabels = [ "bare-metal:host" ];
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
      checkReversePath = lib.mkForce false;
    };
    hostName = "isaiah";
    interfaces.enp38s0.useDHCP = true;
    useDHCP = false;
  };

  services = {
    k3s.clusterInit = true; # This is the first node in the cluster
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };
}
