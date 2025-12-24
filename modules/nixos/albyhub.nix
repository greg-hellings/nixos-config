{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.albyhub;
in
{
  options = {
    services.albyhub = {
      enable = lib.mkEnableOption "Enable the Alby Hub service";

      group = lib.mkOption {
        type = types.str;
        default = "albyhub";
        description = "Group to add user to, and give process permissions for";
      };

      openFirewall = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Automatically open firewall access for this service.";
      };

      package = lib.mkPackageOption pkgs "albyhub" { };

      user = lib.mkOption {
        type = types.str;
        default = "albyhub";
        description = "User to run the service as";
      };

      settings = {
        database = lib.mkOption {
          type = types.str;
          default = "${cfg.workDir}/database.db";
          description = "Either a path to the SQLite database location or a Postgres URI";
        };

        logLevel = lib.mkOption {
          type = types.int;
          default = 4;
          description = "Higher integers are more verbose logging. Default is 4, which is info";
        };

        port = lib.mkOption {
          type = types.int;
          default = 8080;
          description = "Port for the service to listen on";
        };

        relay = lib.mkOption {
          type = types.listOf types.str;
          default = [ "wss://relay.getalby.com/v1" ];
          description = "List of relays for Albyhub to connect to.";
        };

        workDir = lib.mkOption {
          type = types.str;
          default = "/var/lib/albyhub";
          description = "Work directory for Alby Hub";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.port > 0 && cfg.settings.port <= 65535;
        message = "Alby hub port must be an integer between 1 and 65535";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];

    systemd.services.albyhub = {
      after = [ "network-online.target" ];
      environment = {
        LOG_LEVEL = builtins.toString cfg.settings.logLevel;
        PORT = builtins.toString cfg.settings.port;
        RELAY = builtins.concatStringsSep "," cfg.settings.relay;
        WORK_DIR = cfg.settings.workDir;
      };
      requiredBy = [ "multi-user.target" ];
      script = "${lib.getExe cfg.package}";
      wants = [ "network-online.target" ];

      serviceConfig = {
        DynamicUser = true;
        Group = cfg.group;
        ReadWritePaths = cfg.settings.workDir;
        Restart = "always";
        User = cfg.user;
      };
    };

    users = {
      groups.${cfg.group} = { };
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };
  };
}
