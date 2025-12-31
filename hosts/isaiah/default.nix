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

  age.secrets = {
    gitea-runner-isaiah-podman.file = ../../secrets/gitea/runner-isaiah-podman.age;
    gitea-workerPassword.file = ../../secrets/gitea/workerPassword.age;
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
  };

  fileSystems = {
    "/media/proxmox" = {
      device = "10.42.1.4:/volume1/proxmox";
      fsType = "nfs";
      options = [ "noatime" ];
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
    gitea-actions-runner.instances.podman = {
      enable = true;
      labels = [
        "debian-latest:docker://node:25-trixie"

        "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"
        "ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04"
        "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04"

        "ubuntu-full-latest:docker://ghcr.io/catthehacker/ubuntu:full-latest"
        "ubuntu-full-24.04:docker://ghcr.io/catthehacker/ubuntu:full-24.04"
        "ubuntu-full-22.04:docker://ghcr.io/catthehacker/ubuntu:full-22.04"

        "ubuntu-act-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
        "ubuntu-act-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
        "ubuntu-act-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"

        "ubuntu-runner-latest:docker://ghcr.io/catthehacker/ubuntu:runner-latest"
        "ubuntu-runner-24.04:docker://ghcr.io/catthehacker/ubuntu:runner-24.04"
        "ubuntu-runner-22.04:docker://ghcr.io/catthehacker/ubuntu:runner-22.04"

        "ubuntu-rust-latest:docker://ghcr.io/catthehacker/ubuntu:rust-latest"
        "ubuntu-rust-24.04:docker://ghcr.io/catthehacker/ubuntu:rust-24.04"
        "ubuntu-rust-22.04:docker://ghcr.io/catthehacker/ubuntu:rust-22.04"

        "nix-latest:docker://src.thehellings.com/greg/builder:latest"
      ];
      name = "isaiah-podman";
      tokenFile = config.age.secrets.gitea-runner-isaiah-podman.path;
      url = "https://gitea.shire-zebra.ts.net";
    };
    k3s.clusterInit = true; # This is the first node in the cluster
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };
}
