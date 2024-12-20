{ pkgs, config, ... }:

{
  greg.vmdev.enable = true;

  virtualisation = {
    waydroid.enable = false;
    lxd.enable = false;
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
}
