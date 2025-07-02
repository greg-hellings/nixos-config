{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jqp
    iamb
    impala
    rainfrog
    tenere
    wiki-tui
  ];
}
