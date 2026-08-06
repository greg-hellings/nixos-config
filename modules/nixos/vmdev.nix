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
      host = mkOption {
        type = types.enum [
          "libvirt"
          "vbox"
        ];
        description = "Which VM hosting type to configure";
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
      virtio-win
      xorriso
    ];

    users.users."${cfg.user}".extraGroups = [ "libvirtd" ];

    # Enable the virtualisation services
    virtualisation = {
      libvirtd = mkIf (cfg.host == "libvirt") {
        enable = true;
        onBoot = "ignore"; # Do not auto-restart VMs on boot, unless they are marked autostart
        qemu = {
          swtpm = {
            enable = true;
            package = pkgs.swtpm;
          };
        };
      };
      virtualbox.host = mkIf (cfg.host == "vbox") {
        enable = true;
        enableExtensionPack = true;
        headless = true;
      };
    };

    boot.extraModprobeConfig = "options kvm_${cfg.system} nested=1";
  };
}
