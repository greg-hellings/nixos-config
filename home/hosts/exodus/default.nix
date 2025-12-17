{ pkgs, ... }:

{
  greg = {
    development = true;
    gnome = true;
    gui = true;
    vscodium = false;
    zed = true;
  };
  home.packages = with pkgs; [
    bitwarden-cli
    cargo
    devcontainer
    freeciv
    gimp
    gnucash
    k9s
    kdePackages.kdenlive
    kubernetes-helm
    kubectl
    kubectl-cnpg
    moonlight-qt
    mumble
    pre-commit
    wineWowPackages.stable
  ];
}
