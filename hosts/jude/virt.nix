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
  greg.vmdev.enable = true;

  age.secrets.runner-reg.file = ../../secrets/gitlab/isaiah-vbox-runner-reg.age;

  # These options enable sharing of the GPU with the VM
  boot = {
    # Order matters here, to prevent the AMD driver from getting to the driver before
    # vfio-pci does
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"

      "amdgpu"
      #"nvidia"
      #"nvidia_modeset"
      #"nvidia_uvm"
      #"nvidia_drm"
    ];
    kernelParams = [
      "amd_iommu=on"
      ("vfio-pci.ids=" + (lib.concatStringsSep "," passthru))
    ];
  };
  hardware.opengl.enable = true;

  services.gitlab-runner = {
    enable = true;
    settings.concurrent = 5;
    services.vbox = {
      executor = "shell";
      limit = 5;
      authenticationTokenConfigFile = config.age.secrets.runner-reg.path;
      environmentVariables = {
        EFI_DIR = "${pkgs.OVMF.fd}/FV/";
      };
    };
  };

  systemd.services = {
    gitlab-runner = {
      conflicts = [ "libvirtd.service" ];
      preStart = builtins.concatStringsSep "\n" [
        "${pkgs.kmod}/bin/modprobe vboxnetflt vboxdrv"
        "${pkgs.kmod}/bin/modprobe vboxnetadp"
      ];
      postStop = "${pkgs.kmod}/bin/rmmod vboxnetflt vboxnetadp vboxdrv";
      wantedBy = pkgs.lib.mkForce [ ];
      serviceConfig.User = "root";
    };
  };

  virtualisation = {
    libvirtd.hooks.qemu =
      {
      };

    spiceUSBRedirection.enable = true;
  };
}
