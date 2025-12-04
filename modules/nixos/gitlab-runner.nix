{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.greg.runner;
  environmentVariables = {
    EFI_DIR = "${pkgs.OVMF.fd}/FV/";
    STORAGE_URL = "s3.thehellings.lan:9000";
  };
  runnerCfg = file: {
    inherit environmentVariables;
    authenticationTokenConfigFile = file;
    executor = "shell";
    limit = cfg.threads;
  };
in
# We want exactly one of these to be true, but not both. Neither can both be false
{
  options.greg.runner = {
    enable = lib.mkEnableOption "Enable as a gitlab-runner with both libvirt and virtualbox";

    threads = lib.mkOption {
      default = 5;
      type = lib.types.int;
      description = "The maximum number of concurrent jobs";
    };

    qemu = lib.mkEnableOption "Enable the qemu host (mutually exclusive with vbox)";
    vbox = lib.mkEnableOption "Enable the vbox host (mutually exclusive with qemu)";
  };

  config = lib.mkIf cfg.enable ({
    # assertions = [
    #   {
    #     assertion = cfg.qemu || cfg.vbox && (cfg.qemu != cfg.vbox);
    #     message = "You must enable exactly one of qemu or vbox";
    #   }
    # ];
    # Shared configurations
    age.secrets = {
      qemu.file = ../../secrets/gitlab/nixos-qemu-shell.age;
      vbox.file = ../../secrets/gitlab/nixos-vbox-shell.age;
    };

    services.gitlab-runner = {
      enable = false;
      settings.concurrent = cfg.threads;
      services = {
        qemu = lib.mkIf cfg.qemu (runnerCfg config.age.secrets.qemu.path);
        vbox = lib.mkIf cfg.vbox (runnerCfg config.age.secrets.vbox.path);
      };
    };

    systemd.services.gitlab-runner = {
      serviceConfig = {
        DevicePolicy = lib.mkForce "auto";
        User = "root";
        DynamicUser = lib.mkForce false;
      };
    };

    users.extraGroups.vboxusers.members = lib.optional cfg.vbox "greg";

    virtualisation = {
      libvirtd = lib.mkIf cfg.qemu {
        enable = true;
        allowedBridges = [
          "br0"
          "virbr0"
        ];
        onBoot = "ignore"; # only restart VMs labeled 'autostart'
      };
      virtualbox.host = lib.mkIf cfg.vbox {
        enable = true;
        enableExtensionPack = true;
      };
    };
  });
}
