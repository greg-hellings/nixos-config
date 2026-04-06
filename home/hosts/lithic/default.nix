{
  pkgs,
  lib,
  ...
}:
let
  username = "greg";
in
{
  # Disables hitting local cache
  _module.args.cache = lib.mkForce false;
  greg = {
    development = true;
    gui = true;
    nix.cache = false;
    zed = true;
  };

  home = {
    packages = with pkgs; [
      ansible
      awscli2
      cargo
      direnv
      home-manager
      python3Packages.ipython
      just
      nixVersions.stable
      pre-commit
      rustc
    ];
    username = username;
    homeDirectory = "/Users/${username}";
  };

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
    nushell = {
      enable = true;
    };
    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        directory = {
          home_symbol = "~";
          truncate_to_repo = false;
          truncation_length = 0;
          use_os_path_sep = true;
        };
      };
    };
  };
}
