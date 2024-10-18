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
    nix.settings.trusted-users = [ config.users.users.remote-builder-user.name ];
  };
}
