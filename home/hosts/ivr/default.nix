{
  pkgs,
  lib,
  ...
}:
let
  py = pkgs.python311.withPackages (
    p: with p; [
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
    zed = true;
  };

  home = {
    packages = with pkgs; [
      aacs
      ansible
      bitwarden-cli
      direnv
      home-manager
      k9s
      kubectl
      minikube
      mise
      mysql-workbench
      nixStable
      pipenv-ivr
      (poetry.withPlugins (
        ps: with ps; [
          poetry-audit-plugin
          poetry-plugin-export
          poetry-plugin-shell
        ]
      ))
      pre-commit
      robo3t
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
    username = "gregory.hellings";
    homeDirectory = lib.mkForce "/home/gregory.hellings";
  };
  programs.tmux.shell = (lib.getExe x);
  services.podman = {
    enable = true;
    settings = {
      registries.search = [
        "docker.io"
        "quay.io"
      ];
    };
  };
}
