{
  pkgs,
  lib,
  username,
  ...
}:
{
  # Disables hitting local cache
  _module.args.cache = lib.mkForce false;
  greg = {
    development = true;
    gui = true;
    nix.cache = false;
    vscodium = false;
  };

  home = {
    packages = with pkgs; [
      ansible
      direnv
      home-manager
      python3Packages.ipython
      just
      go
      gopls
      mariadb
      nixVersions.stable
      pipenv-ivr
      pre-commit
      python311
      python3Packages.flake8
      twine
    ];
    file = {
      ".pip/pip.conf".text = ''
        [global]
        retries = 1
        index-url = https://pypi.python.org/simple
        extra-index-url =
            https://pypidev.ivrtechnology.com/simple/
      '';
      ".config/uv/uv.toml".text = ''
        [[index]]
        url = "https://pypidev.ivrtechnology.com/simple/"
        name = "pypidev"
      '';
    };
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
    ssh.matchBlocks = lib.listToAttrs (
      lib.map
        (key: {
          name = "${key}.ivrtechnology.com";
          value = { };
        })
        [
          "apidev1"
          "asdev1"
          "agidev1"
          "kdev1"
          "kdev2"
          "kdev3"
          "webdev4"
          "webdev5"

          "web4"
        ]
    );
  };
}
