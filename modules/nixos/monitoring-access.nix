{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.greg.monitoring-access;
in
with lib;
{
  options.greg.monitoring-access = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Create a dedicated, read-only account (`emily`) for automated
        monitoring and analysis by the Hermes agent. The account is
        SSH-key-only (no password set), is not added to `wheel`, and is
        granted no sudo rights. It only gets read access to the systemd
        journal via group membership, which is sufficient for log
        inspection and health/analysis tasks without any privileged
        access to the rest of the system.
      '';
    };

    sshKeys = mkOption {
      type = types.listOf types.str;
      default = lib.strings.splitString "\n" (
        builtins.readFile ../../home/ssh/emily_authorized_keys
      );
      description = "SSH public keys authorized to log in as the monitoring account.";
    };
  };

  config = mkIf cfg.enable {
    users.groups.emily = { };

    users.users.emily = {
      isNormalUser = true;
      createHome = true;
      description = "Read-only monitoring/analysis account (Hermes agent)";
      group = "emily";
      # No password is set on purpose: this account is SSH-key-only.
      extraGroups = [
        "systemd-journal" # read access to the journal for log analysis
      ];
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = cfg.sshKeys;
    };
  };
}
