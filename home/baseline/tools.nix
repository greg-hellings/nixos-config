{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    dnsutils
    jqp
    iamb
    rainfrog
    tenere
    wiki-tui
  ] ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    impala
  ]);
}
