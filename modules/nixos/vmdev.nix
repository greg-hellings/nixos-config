{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.greg.vmdev;
in
with lib;
{
  options = {
    greg.vmdev = {
      enable = mkEnableOption "Enable this system for VM development work";
      user = mkOption {
        default = "greg";
        type = types.str;
        description = "The user who will be doing VM dev";
      };
      system = mkOption {
        default = "amd";
        type = types.str;
        description = "Kernel module type to install - amd, intel, etc";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dmidecode
      guestfs-tools
      libguestfs
      OVMFFull
      packer
      virt-manager
      xorriso
    ];

    users.users."${cfg.user}".extraGroups = [ "libvirtd" ];

    # Enable the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        onBoot = "ignore"; # Do not auto-restart VMs on boot, unless they are marked autostart
        qemu.ovmf.enable = true;
      };

      virtualbox.host = {
        enable = true;
        enableExtensionPack = true;
      };
    };

    # Configuration for vbox user performance
    users.extraGroups.vboxusers.members = [ cfg.user ];

    boot.extraModprobeConfig = "options kvm_${cfg.system} nested=1";

    # Configure the services more
    systemd.services = {
      libvirtd = {
        preStart = "${pkgs.kmod}/bin/modprobe kvm_${cfg.system}";
        postStop = "${pkgs.kmod}/bin/rmmod kvm_${cfg.system} kvm";
        conflicts = [ "vbox.service" ];
      };
      vbox = {
        preStart = "${pkgs.kmod}/bin/modprobe vboxdrv vboxnetadp vboxnetflt";
        postStop = "${pkgs.kmod}/bin/rmmod vboxnetadp vboxnetflt vboxdrv";
        script = "echo Started";
        conflicts = [ "libvirtd.service" ];
        unitConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };
    };
  };
}
