{ lib, pkgs, ... }:

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
    just
    k9s
    kdePackages.kdenlive
    kubernetes-helm
    kubectl
    kubectl-cnpg
    mattermost-desktop
    mumble
    nebula
    nix-index
    adoptopenjdk-icedtea-web
    pre-commit
    prismlauncher
    (python311.withPackages (p: [
      p.virtualenv
    ]))
    rclone
    restic
    restic-browser
    tea
    uv
    wineWow64Packages.stable
  ];
  programs = {
    discord = {
      enable = true;
      settings.SKIP_HOST_UPDATE = true;
    };
  };
  xdg.desktopEntries = {
    prismlauncher = {
      name = "Prism Launcher - Minecraft";
      actions.minecraft = {
        name = "Minecraft";
        exec = lib.getExe pkgs.prismlauncher;
      };
    };
  };
}
