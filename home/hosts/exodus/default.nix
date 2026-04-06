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
    mattermost-desktop
    minio-client
    mumble
    pre-commit
    restic
    restic-browser
    tea
    wineWow64Packages.stable
  ];
  programs = {
    discord = {
      enable = true;
      settings.SKIP_HOST_UPDATE = true;
    };
  };
}
