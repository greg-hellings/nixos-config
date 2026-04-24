{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.greg.adblockUpdate;
in
{

  options.greg.adblockUpdate = {
    enable = lib.mkEnableOption "Enable auto-update of block list";
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.adblock-update = {
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
        script = lib.getExe pkgs.adblockUpdate;
        serviceConfig.Type = "oneshot";
      };
      timers.adblock-update = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Unit = "adblock-update.service";
        };
      };
    };
  };
}
