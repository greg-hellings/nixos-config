{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.greg.gitea-runner;
in
{
  options.greg.gitea-runner = {
    enable = lib.mkEnableOption "Enable Gitea act_runner (shell mode)";

    instanceURL = lib.mkOption {
      type = lib.types.str;
      default = "https://src.thehellings.com";
      description = "URL of the Gitea instance to connect to";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Name of the runner (defaults to hostname)";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "self-hosted" ];
      description = "Labels to assign to this runner";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the runner registration token (from agenix)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea-actions-runner = {
      package = pkgs.gitea-actions-runner;
      instances.${cfg.name} = {
        enable = true;
        url = cfg.instanceURL;
        tokenFile = cfg.tokenFile;
        labels = cfg.labels;
      };
    };
  };
}
