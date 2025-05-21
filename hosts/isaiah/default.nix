{
  config,
  lib,
  top,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    top.proxmox.nixosModules.proxmox-ve
  ];

  age.secrets = {
    runner-reg.file = ../../secrets/gitlab/kubernetes-k3s-local.age;
  };

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

  greg = {
    kubernetes.enable = true;
    tailscale.enable = true;
    remote-builder.enable = true;
  };

  fileSystems = {
    "/media/proxmox" = {
      device = "10.42.1.4:/volume1/proxmox";
      fsType = "nfs";
      options = [ "noatime" ];
    };
  };

  networking = {
    defaultGateway = {
      address = " 10.42.1.1";
      interface = "enp38s0";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
      checkReversePath = lib.mkForce false;
    };
    hostName = "isaiah";
    interfaces = {
      enp38s0 = {
        ipv4.addresses = [
          {
            address = "10.42.1.6";
            prefixLength = 16;
          }
        ];
      };
    };
    nameservers = [ "10.42.1.5" ];
    useDHCP = false;
  };

  services = {
    gitlab-runner = {
      enable = true;
      settings = {
        concurrent = 5;
      };
      services = {
        kubernetes = {
          authenticationTokenConfigFile = config.age.secrets.runner-reg.path;
          executor = "shell";
        };
      };
    };
    k3s.clusterInit = true; # This is the first node in the cluster
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      allowedBridges = [
        "br0"
        "virbr0"
      ];
      onBoot = "ignore"; # only restart VMs labeled 'autostart'
      qemu.ovmf.enable = true;
    };
  };
}
