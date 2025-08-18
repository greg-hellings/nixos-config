{
  config,
  lib,
  ...
}:
{
  programs = {
    nushell = {
      enable = true;
      environmentVariables = config.home.sessionVariables;
      extraConfig = ''
        use std/util "path add"
        path add ${config.home.homeDirectory}/src/bin
        path add /opt/homebrew/bin
        path add /run/current-system/sw/bin
        path add ${config.home.homeDirectory}/.nix-profile/bin
      '';
      settings = {
        buffer_editor = lib.getExe config.programs.nixvim.package;
        "history.isolation" = true;
        "history.file_format" = "sqlite";
      };
    };
  };
  home.shell.enableNushellIntegration = true;
}
