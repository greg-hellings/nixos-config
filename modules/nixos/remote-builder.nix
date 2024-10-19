{ lib, config, ... }:

let
  cfg = config.greg.remote-builder;
in
with lib;
{
  options.greg.remote-builder = {
    enable = mkEnableOption "Enable this as a remote builder for myself";
  };

  config = mkIf cfg.enable {
    greg.tailscale.enable = true;
    users.users.remote-builder-user = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4fNCnomQEsFKQZp16LXRqkfXHzzZbGAYJWPMvlGGQy root@exodus"
      ];
      homeMode = "500";
      isNormalUser = true;
      useDefaultShell = true;
    };
    # The builder user needs to be trusted to submit builds
    nix.settings.trusted-users = [ config.users.users.remote-builder-user.name ];
    # If the system is powerful enough to be a remote builder, it should
    # be powerful enough to do some basic qemu stuff
    boot.binfmt.emulatedSystems = [
      "i686-linux"
      "aarch64-linux"
    ];
  };
}
