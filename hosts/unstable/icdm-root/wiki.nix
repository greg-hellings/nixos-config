{ pkgs, ... }:
let
  wikiHost = "wiki.icdm.lan";
  kiwixport = 8080;
in
{
  services.kiwix-serve = {
    enable = true;
    port = kiwixport;
    library = {
      inherit (pkgs) zim;
    };
  };

  greg.proxies."${wikiHost}".target = "http://localhost:${toString kiwixport}";
  networking.firewall.allowedTCPPorts = [ 80 ];
}
