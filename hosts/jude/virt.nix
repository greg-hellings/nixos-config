{
  config,
  lib,
  pkgs,
  ...
}:

let
  passthru = [
    "1002:164e" # Raphael - embedded GPU
    "1002:1640" # Rembrandt - Audio
    #"10de:2507" # RTX 3050 video
    #"10de:228e" # RTX 3050 audio
  ];
in
{
  specialisation = {
    vbox.configuration = {

      greg = {
        podman.enable = lib.mkForce false;
        vmdev.enable = lib.mkForce false;
      };

      users.extraGroups.vboxusers.members = [ "greg" ];

      virtualisation = {
        virtualbox.host = {
          enable = true;
          enableExtensionPack = true;
        };
      };

      services.gitlab-runner.services = lib.mkForce {
        vbox = {
          authenticationTokenConfigFile = config.age.secrets.vbox.path;
          environmentVariables = {
            EFI_DIR = "${pkgs.OVMF.fd}/FV/";
          };
          executor = "shell";
          limit = 5;
        };
      };

      systemd.services.gitlab-runner = {
        serviceConfig = {
          DevicePolicy = lib.mkForce "auto";
          User = "root";
          DynamicUser = lib.mkForce false;
        };
      };
    };
  };

  age.secrets = {
    qemu.file = ../../secrets/gitlab/nixos-qemu-shell.age;
    vbox.file = ../../secrets/gitlab/nixos-vbox-shell.age;
  };

  # These options enable sharing of the GPU with the VM
  boot = {
    # Order matters here, to prevent the AMD driver from getting to the driver before
    # vfio-pci does
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"

      #"amdgpu"
      #"nvidia"
      #"nvidia_modeset"
      #"nvidia_uvm"
      #"nvidia_drm"
    ];
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      ("vfio-pci.ids=" + (lib.concatStringsSep "," passthru))
    ];
  };

  greg.vmdev.enable = true;

  hardware.graphics.enable = true;

  services.gitlab-runner = {
    enable = true;
    settings.concurrent = 5;
    services.qemu = {
      executor = "shell";
      limit = 5;
      authenticationTokenConfigFile = config.age.secrets.qemu.path;
      environmentVariables = {
        EFI_DIR = "${pkgs.OVMF.fd}/FV/";
      };
    };
  };

  systemd.services = {
    "libvirt-nosleep@" = {
      description = "Prevent sleep while %i is running";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why="Libvirt domain %i is running" --who=%U --mode=block sleep infinity
        '';
      };
    };
  };

  virtualisation = {
    libvirtd = {
      extraConfig = ''
        log_filters="1:qemu"
        log_outputs="1:file:/var/log/libvirt/libvirtd.log"
      '';
      hooks.qemu = {
        win10 = lib.getExe pkgs.qemu-hook;
      };
    };

    spiceUSBRedirection.enable = true;
  };
}
