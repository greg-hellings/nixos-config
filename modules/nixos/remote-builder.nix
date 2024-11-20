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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGJjyFVOsF74QKzRITc8z/5MJlIa47P1tMm9Z8HRJLm root@jude"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMOdWSq6NtcP6sfe2uke4wSfgE16hfa970t+8ADdLwk root@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwbFyuS9zcwZ7hGSpAWtx9NJq/elSLN8jYpr+/1nXd8 root@linode"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXza2Pj05pdzGbiPDc/RF13nHhIZZ63u/WV/BS7bOjf root@genesis"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTNTcHmNFB931L5vDAsdOkTc9wFyGpuTMdhc0VYLXME root@isaiah"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJc/EIBk7lRKBsJQ5Lindz0WIRNUE1z9xeUqhsRN9Pus root@jeremiah"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLOqwbp4hFYkiJpokh9i2RToa/6tQcwthDNQH69tyBF root@vm-matrix.thehellings.lan"
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
