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
      #guestfs-tools
      libguestfs
      OVMFFull
      nixos-generators
      packer
      swtpm
      virt-manager
      virtio-win
      xorriso
    ];

    users.users."${cfg.user}".extraGroups = [ "libvirtd" ];

    # Enable the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        onBoot = "ignore"; # Do not auto-restart VMs on boot, unless they are marked autostart
        qemu = {
          swtpm = {
            enable = true;
            package = pkgs.swtpm;
          };
        };
      };
    };

    boot.extraModprobeConfig = "options kvm_${cfg.system} nested=1";
  };
}
