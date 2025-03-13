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
    cargo
    freeciv
    #freeciv_qt
    wineWowPackages.stable
  ];
}
