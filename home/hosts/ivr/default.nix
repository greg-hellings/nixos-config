{
  pkgs,
  lib,
  ...
}:
let
  username = "gregory.hellings";
  x = pkgs.xonsh.override {
    extraPackages = (
      ps: [
        pkgs.nur.repos.xonsh-xontribs.xonsh-direnv
        pkgs.nur.repos.xonsh-xontribs.xontrib-vox
        ps.xonsh-apipenv
        pkgs.pipenv-ivr
      ]
    );
  };
in
{
  # Disables hitting local cache
  _module.args.cache = lib.mkForce false;
  greg = {
    development = true;
    gui = true;
    nix.cache = false;
    pypackage.enable = false;
    vscodium = true;
  };

  home = {
    packages = with pkgs; [
      aacs
      ansible
      direnv
      home-manager
      just
      go
      gopls
      k9s
      kubectl
      mariadb
      minikube
      mise
      nil
      nixStable
      pipenv-ivr
      pre-commit
      python311
      python3Packages.flake8
      skaffold
      x
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
        url = "https://pypidev.ivrtechnology.com"
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
    tmux.shell = (lib.getExe x);
  };
}
