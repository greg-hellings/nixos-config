{ pkgs, ... }:
let
  wikiHost = "wiki.icdm.lan";
  kiwixport = 8080;
  dependents = with pkgs; [
    enwiki-dump
    transmission
  ];
in
{
  services.kiwix-serve = {
    enable = true;
    port = kiwixport;
    path = "/srv/zims/*.zim";
  };

  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/srv";
      incomplete-dir = "/srv/incomplete";
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "10.42.*,127.*,localhost";
    };
  };

  greg.proxies."${wikiHost}".target = "http://localhost:${toString kiwixport}";
  networking.firewall.allowedTCPPorts = [ 80 ];

  environment.systemPackages = dependents;
}
