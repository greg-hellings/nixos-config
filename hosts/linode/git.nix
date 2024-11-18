{ ... }:

let
  srcDomain = "src.thehellings.com";
  sshPort = 2222;
in
{
  greg.proxies."${srcDomain}" = {
    target = "http://git.thehellings.lan";
    ssl = true;
    genAliases = false;
    extraConfig = ''
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header X-Forwarded-Ssl on;
      client_max_body_size 100000m;
    '';
  };
  greg.proxies."registry.thehellings.com" = {
    target = "https://registry.thehellings.lan:5000";
    ssl = true;
    genAliases = false;
    extraConfig = "client_max_body_size 250m;";
  };

  networking.firewall.allowedTCPPorts = [ sshPort ];

  systemd.services.haproxy = {
    after = [ "sys-devices-virtual-net-tailscale0.device" ];
  };

  services.haproxy = {
    enable = true;
    config = builtins.concatStringsSep "\n" [
      "global"
      "	daemon"
      "	maxconn 20"

      "defaults"
      "	timeout connect 500s"
      "	timeout client 500s"
      "	timeout server 1h"

      "listen gitsshd"
      "	bind *:${toString sshPort}"
      "	timeout client 1h"
      "	mode tcp"
      "	server git-thehellings-lan git.thehellings.lan:22"
    ];
  };
}
