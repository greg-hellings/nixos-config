{
  config,
  lib,
  ...
}:
{
  programs = {
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
    nushell = {
      enable = true;
      environmentVariables = {
        AWS_SHARED_CREDENTIALS_FILE = "/run/agenix/cache-credentials";
        GOPATH = "${config.home.homeDirectory}/src/go";
        GOBIN = "${config.home.homeDirectory}/src/bin";
        LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN = "1";
        SWORD_PATH = "${config.home.homeDirectory}/.sword/";
        #TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
        VIRTUALENV_HOME = "${config.home.homeDirectory}/venv/";
      };
      extraConfig = ''
        use std/util "path add"
        path add ${config.home.homeDirectory}/src/bin
        path add /opt/homebrew/bin
        path add /run/current-system/sw/bin
        path add ${config.home.homeDirectory}/.nix-profile/bin
      '';
      settings = {
        buffer_editor = lib.getExe config.programs.nixvim.package;
      };
    };
    starship = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
