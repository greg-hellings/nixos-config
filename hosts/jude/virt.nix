{ pkgs, config, ... }:

{
  greg.vmdev.enable = true;

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

  age.secrets.runner-reg.file = ../../secrets/gitlab/isaiah-vbox-runner-reg.age;

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

  virtualisation = {
    libvirtd.hooks.qemu = {
      "win11-prepare-begin-bind_vfio.sh" = pkgs.writeShellApplication {
        name = "bind_vfio.sh";
        runtimeInputs = with pkgs; [
          kmod
          libvirt
        ];
        text = ''
          guest="$1"
          stage="$2"
          state="$3"

          if [ "$guest" == "win11" ] && [ "$stage" == "prepare" ] && [ "$state" == "begin" ]; then
            for f in vfio vfio_iommu_type1 vfio_pci; do
              modprobe "$f"
            done

            virsh nodedev-detach pci_0000_10_00_0
            virsh nodedev-detach pci_0000_10_00_1
          fi
        '';
      };

      "win11-release-end-unbind_vfio.sh" = pkgs.writeShellApplication {
        name = "unbind_vfio.sh";
        runtimeInputs = with pkgs; [
          kmod
          libvirt
        ];
        text = ''
          guest="$1"
          stage="$2"
          state="$3"

          if [ "$guest" == "win11" ] && [ "$stage" == "release" ] && [ "$state" == "end" ]; then
            virsh nodedev-reattach pci_0000_10_00_1
            virsh nodedev-reattach pci_0000_10_00_0

            for f in vfio_pci vfio_iommu_type1 vfio; do
              modprobe -r "$f"
            done
          fi
        '';
      };
    };
    lxd.enable = false;
    waydroid.enable = false;
  };
}
