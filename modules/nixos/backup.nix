{
  lib,
  config,
  ...
}:

let
  cfg = config.greg.backup;

  makeSyncFolders = _: job: {
    inherit (job) user;
    backupCleanupCommand = lib.optionalString (job.post != "") job.post;
    backupPrepareCommand = lib.optionalString (job.pre != "") job.pre;
    extraOptions = [
      "--insecure-tls"
      "--insecure-no-password"
    ];
    initialize = true;
    environmentFile = config.age.secrets.restic-env.path;
    passwordFile = config.age.secrets.restic-pw.path;
    paths = [ job.src ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
    repository = "rest:https://nas1.shire-zebra.ts.net:30248/${job.dest}";
  };
in
with lib;
{
  options = {
    greg.backup = {
      jobs = mkOption {
        default = { };

        type =
          with types;
          attrsOf (
            submodule (
              { ... }:
              {
                options = {
                  src = mkOption {
                    type = types.str;
                    description = "Local path (string form) to backup from";
                  };

                  dest = mkOption { type = types.str; };

                  user = mkOption {
                    type = types.str;
                    default = "root";
                    description = "User to run backup as - defaults to root";
                  };

                  pre = mkOption {
                    type = types.str;
                    default = "";
                  };

                  post = mkOption {
                    type = types.str;
                    default = "";
                  };
                };
              }
            )
          );
      };
    };
  };

  config = mkIf ((attrValues cfg.jobs) != [ ]) {
    age.secrets = {
      restic-pw.file = ../../secrets/restic-pw.age;
      restic-env.file = ../../secrets/restic-env.age;
    };
    services = {
      restic.backups = mapAttrs makeSyncFolders cfg.jobs;
    };
  };
}
