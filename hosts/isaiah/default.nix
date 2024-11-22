{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./git.nix
  ];

  greg = {
    tailscale.enable = true;
    remote-builder.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "br0"
      "virbr0"
    ];
    onBoot = "ignore"; # only restart VMs labeled 'autostart'
    qemu.ovmf.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };
  networking = {
    hostName = "isaiah";
    useDHCP = false;
    bridges.br0 = {
      interfaces = [ "enp38s0" ];
    };
    defaultGateway = {
      address = " 10.42.1.1";
      interface = "br0";
    };
    interfaces = {
      br0 = {
        ipv4.addresses = [
          {
            address = "10.42.1.6";
            prefixLength = 16;
          }
        ];
      };
    };
    nameservers = [ "10.42.1.5" ];
    firewall.checkReversePath = lib.mkForce false;
  };
  users = {
    users = {
      greg = {
        extraGroups = [
          "kvm"
          "libvirtd"
          "sudo"
          "wheel"
        ];
        isNormalUser = true;
      };
    };
  };
  system.stateVersion = lib.mkForce "24.05";
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
        configurationLimit = 10;
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "nodejs-16.20.2" ];
  };
}
