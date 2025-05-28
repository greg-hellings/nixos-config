{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.greg.pypackage;
in
{
  options.greg.pypackage = {
    enable = lib.mkOption {
      description = "Enable installing my Python package here";
      type = lib.types.bool;
      default = true;
    };
    package = lib.mkOption {
      description = "Enable Gnome support and settings";
      type = lib.types.package;
      default = pkgs.gregpy;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
