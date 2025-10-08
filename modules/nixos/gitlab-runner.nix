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
in
{
  options.greg.runner = {
    enable = lib.mkEnableOption "Enable as a gitlab-runner with both libvirt and virtualbox";

    threads = lib.mkOption {
      default = 5;
      type = lib.types.int;
      description = "The maximum number of concurrent jobs";
    };
  };

  config = lib.mkIf cfg.enable {
    # Shared configurations
    age.secrets = {
      qemu.file = ../../secrets/gitlab/nixos-qemu-shell.age;
      vbox.file = ../../secrets/gitlab/nixos-vbox-shell.age;
    };

    # Defaults to running libvirt support
    services.gitlab-runner = {
      enable = true;
      settings.concurrent = cfg.threads;
      services.qemu = {
        inherit environmentVariables;
        executor = "shell";
        limit = cfg.threads;
        authenticationTokenConfigFile = config.age.secrets.qemu.path;
      };
    };

    systemd.services.gitlab-runner = {
      serviceConfig = {
        DevicePolicy = lib.mkForce "auto";
        User = "root";
        DynamicUser = lib.mkForce false;
      };
    };

    virtualisation = {
      libvirtd = {
        enable = lib.mkDefault true;
        allowedBridges = [
          "br0"
          "virbr0"
        ];
        onBoot = "ignore"; # only restart VMs labeled 'autostart'
        qemu.ovmf.enable = true;
      };
    };
    # Boot into this specialisation if you want to build vbox hosts
    # with this box at that time
    specialisation = {
      vbox.configuration = {
        users.extraGroups.vboxusers.members = [ "greg" ];

        virtualisation = {
          libvirtd.enable = false;
          virtualbox.host = {
            enable = true;
            enableExtensionPack = true;
          };
        };

        services.gitlab-runner.services = lib.mkForce {
          vbox = {
            inherit environmentVariables;
            authenticationTokenConfigFile = config.age.secrets.vbox.path;
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

  };
}
