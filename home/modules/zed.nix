{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.greg.zed;
in
{
  options.greg.zed = lib.mkEnableOption "Whether to install the Zed editor";

  config = lib.mkIf cfg {
    home.packages = with pkgs; [
      nil
      zed-editor
    ];
  };
}
