{
  lib,
  config,
  ...
}:

let
  cfg = config.greg.backup;

  makeSyncFolders = _: job: {
    inherit (job) user;
    initialize = true;
    passwordFile = config.age.secrets.restic-pw.path;
    paths = [ job.src ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
    repository = "rest:nas1.shire-zebra.ts.net:30248/${job.dest}";
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
