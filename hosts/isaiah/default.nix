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
    top.proxmox.nixosModules.proxmox-ve
  ];

  age.secrets = {
    runner-reg.file = ../../secrets/gitlab/isaiah-podman-runner-reg.age;
    docker-auth.file = ../../secrets/gitlab/docker-auth.age;
    runner-qemu.file = ../../secrets/gitlab/isaiah-qemu-runner-reg.age;
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

  environment.systemPackages = with pkgs; [
    curl
    gawk
    git
    unzip
    wget
    zstd
  ];

  greg = {
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
    bridges.br0 = {
      interfaces = [ "enp38s0" ];
    };
    defaultGateway = {
      address = " 10.42.1.1";
      interface = "br0";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
      checkReversePath = lib.mkForce false;
    };
    hostName = "isaiah";
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
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "br0";
    };
    useDHCP = false;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "nodejs-16.20.2" ];
    };
  };

  services = {
    gitlab-runner = {
      enable = true;
      settings = {
        concurrent = 5;
      };
      services = {
        default = {
          executor = "docker";
          authenticationTokenConfigFile = config.age.secrets.runner-reg.path;
          dockerImage = "gitlab.shire-zebra.ts.net:5000/greg/ci-images/fedora:latest";
          dockerAllowedImages = [
            "alpine:*"
            "debian:*"
            "docker:*"
            "fedora:*"
            "python:*"
            "ubuntu:*"
            "registry.gitlab.com/gitlab-org/*"
            "registry.thehellings.com/*/*/*:*"
            "gitlab.shire-zebra.ts.net:5000/*/*/*:*"
          ];
          dockerAllowedServices = [
            "docker:*"
            "registry.thehellings.com/*/*/*:*"
            "gitlab.shire-zebra.ts.net:5000/*/*/*:*"
          ];
          dockerPrivileged = true;
          dockerVolumes = [
            "/certs/client"
            "/cache"
          ];
        };
        # qemu = {
        #   executor = "shell";
        #   limit = 5;
        #   authenticationTokenConfigFile = config.age.secrets.runner-qemu.path;
        #   environmentVariables = {
        #     EFI_DIR = "${pkgs.OVMF.fd}/FV/";
        #     STORAGE_URL = "s3.thehellings.lan:9000";
        #   };
        # };
      };
    };
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    proxmox-ve = {
      enable = true;
      ipAddress = (builtins.elemAt config.networking.interfaces.br0.ipv4.addresses 0).address;
    };
  };

  system.stateVersion = lib.mkForce "24.05";

  systemd.services.gitlab-runner = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
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

  virtualisation = {
    podman.enable = true;
    libvirtd = {
      enable = true;
      allowedBridges = [
        "br0"
        "virbr0"
      ];
      onBoot = "ignore"; # only restart VMs labeled 'autostart'
      qemu.ovmf.enable = true;
    };
    oci-containers.backend = "podman";
  };
}
