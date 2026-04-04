{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.greg.gitea-runner;
  hostname = config.networking.hostName;

  # Determine extra labels based on host role
  roleLabels =
    if builtins.elem hostname [ "isaiah" "jeremiah" "zeke" ] then
      [ "bare-metal" ]
    else if hostname == "linode" then
      [ "linode" ]
    else
      [ ];
in
{
  options.greg.gitea-runner = {
    enable = lib.mkEnableOption "Enable Gitea Actions runner (exec/shell mode)";

    hostnameLabel = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Label identifying this host in the runner pool (defaults to hostname)";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the file containing the runner registration token.
        Wire in your agenix secret path here, e.g.:
          config.age.secrets.gitea-runner-token.path
      '';
    };

    threads = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Maximum number of concurrent jobs";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea-actions-runner = {
      package = pkgs.gitea-actions-runner;
      instances.${hostname} = {
        enable = true;
        url = "https://src.thehellings.com";
        tokenFile = cfg.tokenFile;
        labels =
          [
            "self-hosted"
            cfg.hostnameLabel
          ]
          ++ roleLabels;
        settings = {
          runner.capacity = cfg.threads;
        };
      };
    };
  };
}
