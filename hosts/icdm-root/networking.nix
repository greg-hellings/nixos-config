{ ... }:
let
  dnsHosts = builtins.concatStringsSep "\n" [
    "wiki.icdm.lan 10.42.101.1"
  ];
in
{
  # If we have to do proxying in Bayonnais, we can start to work on that here
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking = {
    hostName = "icdm-root";
    useDHCP = false;
    defaultGateway = "10.42.1.1";
    nameservers = [ "100.100.100.100" "10.42.1.2" ];
    enableIPv6 = false;

    interfaces = {
      eno1.ipv4.addresses = [{
        address = "10.42.101.1";
        prefixLength = 16;
      }
        {
          address = "10.77.1.2";
          prefixLength = 16;
        }];
    };
    # Allow traffic through
    firewall = {
      enable = true;
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 67 ];
    };

    extraHosts = "${dnsHosts}";
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      domain = "icdm.lan";
      dhcp-range = [
        "eno1,10.77.1.10,10.77.1.255,255.255.0.0,12h"
      ];
      dhcp-option = [
        "eno1,option:router,10.77.1.1"
        "eno1,option:dns-server,10.77.1.2,1.1.1.1"
        "eno1,option:domain-search,icdm.lan"
      ];
      expand-hosts = true;
      log-dhcp = true;
      log-queries = true;
      # Upstream servers
      server = [
        "1.1.1.1"
        "8.8.4.4"
      ];
    };
  };
}
