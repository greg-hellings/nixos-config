{ pkgs, ... }:

{
  greg.vscodium.enable = false;

  home.packages = with pkgs; [ brew ];
}
