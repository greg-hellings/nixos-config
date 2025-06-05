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
    pypackage.enable = false;
    vscodium = true;
  };

  home = {
    packages = with pkgs; [
      aacs
      ansible
      direnv
      home-manager
      k9s
      kubectl
      minikube
      mise
      nixStable
      pipenv-ivr
      pre-commit
      skaffold
      x
    ];
    file.".pip/pip.conf".text = (
      lib.strings.concatStringsSep "\n" [
        "[global]"
        "retries = 1"
        "index-url = https://pypi.python.org/simple"
        "extra-index-url ="
        "    https://pypi.ivrtechnology.com/simple/"
        "    https://pypidev.ivrtechnology.com/simple/"
      ]
    );
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
    };
    tmux.shell = (lib.getExe x);
  };
}
