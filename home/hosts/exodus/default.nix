{ pkgs, ... }:

{
  greg = {
    development = true;
    gnome = true;
    gui = true;
    vscodium = true;
    zed = true;
  };
  home.packages = with pkgs; [
    bitwarden-cli
    cargo
    freeciv
    gimp
    k9s
    kubernetes-helm
    kubectl
    kubectl-cnpg
    wineWowPackages.stable
  ];
}
