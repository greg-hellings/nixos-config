{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    dnsutils
    jqp
    iamb
    impala
    rainfrog
    tenere
    wiki-tui
  ];
}
