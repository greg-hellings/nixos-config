{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.greg.backup;

  where = j: "${config.services.syncthing.dataDir}/daily.0/${j.dest}";

  postexec = pkgs.writeShellApplication {
    name = "postexec";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      chown -R ${config.services.syncthing.user} ${config.services.syncthing.dataDir}
    '';
  };

  makeSyncFolders = _: job: {
    devices = [ "chronicles" ];
    enable = true;
    id = job.id;
    label = job.dest;
    path = where job;
    type = "sendonly";
  };

  makeRsnapshot = _: job: "backup	${job.src}/	${job.dest}/";
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

                  id = mkOption {
                    type = types.str;
                    description = "The unique folder ID for this";
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
    greg.syncthing = {
      enable = true;
    };
    services = {
      syncthing.settings.folders = mapAttrs makeSyncFolders cfg.jobs;
      rsnapshot = {
        enable = true;
        enableManualRsnapshot = true;
        extraConfig =
          ''
            snapshot_root	${config.services.syncthing.dataDir}/
            retain	daily	7
            retain	weekly	2
            cmd_postexec	${lib.getExe postexec}
          ''
          + (builtins.concatStringsSep "\n" (mapAttrsToList makeRsnapshot cfg.jobs));
        cronIntervals = {
          daily = "19 02 * * *"; # At 2:19 am every day
          weekly = "19 01 * * 1"; # At 1:19 am every Monday
        };
      };
    };
  };
}
