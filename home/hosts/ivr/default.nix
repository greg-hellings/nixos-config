{
  pkgs,
  lib,
  top,
  ...
}:
let
  nix23 = import top.nix23_05 {
    inherit (pkgs.stdenv) system;
    overlays = [ top.self.overlays.default ];
  };
  py = nix23.python311.withPackages (
    p: with p; [
      django
      djangorestframework
      django-rapyd-modernauth
      environs
      mysqlclient
      pyyaml
      ruamel-yaml
      tox
    ]
  );
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
  greg = {
    development = true;
    gui = true;
    pypackage = py;
    vscodium = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "jitsi-meet-1.0.8043" ];
  };

  home = {
    packages = with pkgs; [
      aacs
      ansible
      bitwarden-cli
      direnv
      home-manager
      mysql-workbench
      pipenv-ivr
      poetry
      robo3t
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
    username = "gregory.hellings";
    homeDirectory = lib.mkForce "/home/gregory.hellings";
  };
  programs.tmux.shell = (lib.getExe x);
}
