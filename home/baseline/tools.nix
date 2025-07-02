{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jqp
    iamb
    rainfrog
    tenere
    wiki-tui
  ];
}
