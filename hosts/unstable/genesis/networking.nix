{
  config,
  lib,
  lib',
  metadata,
  pkgs,
  ...
}:
let
  lan = "enp1s0";
  lanIP = metadata.hosts.${config.networking.hostName}.ip;
  iot = "enp2s0";
  iotIP = "192.168.66.250";
  extraHosts = builtins.readFile ./net/hosts;

  proxyPort = 3128;
  dnsPort = 53;
  dhcpPort = 67;
  dnsServers = [
    #"9.9.9.9" # Quad 9
    #"1.1.1.1" # Cloudflare
    #"1.0.0.1" # Cloudflare
    #"149.112.112.112" # Quad 9
    metadata.infra.gw # Currently using our UniFi router for DNS as well
  ];
in
{
  greg = {
    nebula = {
      enable = true;
      # genesis IS the routing node for the home LAN — it does not route through itself.
      # Override the module default (which points at genesis) to avoid a routing loop.
      unsafeRoutes = [ ];
      # genesis routes the home LAN (10.42.0.0/16) into the Nebula overlay.
      # Sign genesis's cert with -subnets '10.42.0.0/16' (see secrets/nebula/README.md).
      routesSubnet = "10.42.0.0/16";
    };
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
  };

  # Really, why do I still have to force-disable this crap?
  boot.kernel.sysctl = {
    "net.ipv6.conf.${lan}.disable_ipv6" = true;
    "net.ipv6.conf.${iot}.disable_ipv6" = true;
    "net.ipv6.conf.lo.disable_ipv6" = true;
  };

  networking = {
    defaultGateway = metadata.infra.gw;
    enableIPv6 = false;
    networkmanager.enable = pkgs.lib.mkForce false;
    nameservers = dnsServers;
    interfaces = {
      # This is our LAN port
      "${lan}" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "${lanIP}";
            prefixLength = 16;
          }
        ];
      };

      "${iot}" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "${iotIP}";
            prefixLength = 24;
          }
        ];
      };
    };
    firewall = {
      enable = false;
      allowedUDPPorts = [
        dhcpPort
        dnsPort
      ];
      allowedTCPPorts = [
        dnsPort
        proxyPort
        80
      ];
    };
    nftables.enable = false;
  };

  environment.etc."hosts.d/local".text = extraHosts;

  services = {
    #########
    # dnsmasq config
    ########
    bind = {
      enable = true;
      cacheNetworks = [
        metadata.infra.lan
        metadata.infra.tailscale
        metadata.infra.nebula
        "127.0.0.0/8"
      ];
      zones =
        let
          makeZoneFile =
            hosts: domain:
            let
              preamble = [
                "$ORIGIN\t${domain}."
                "$TTL\t1h"
                "@\tIN\tSOA\t${config.networking.hostName}\tgreg@thehellings.com (1 1m 1m 1m 1m)"
                "\tIN\tNS\t${config.networking.hostName}"
              ];
              makeHost = host: "${host.name}\tIN\tA\t${host.address}";
            in
            pkgs.writeText "${domain}" (
              builtins.concatStringsSep "\n" (preamble ++ (lib.map makeHost hosts) ++ [ "" ])
            );
        in
        lib.mapAttrs
          (domain: net: {
            master = true;
            file = makeZoneFile (lib'.hostsByNet net metadata.hosts) domain;
          })
          {
            "shire-zebra.ts.net" = "tailscale";
            "nebula.thehellings.com" = "nebula";
            nebula = "nebula";
            "thehellings.lan" = "lan";
            lan = "lan";
          };
    };
  }; # End of services configuration

  environment.systemPackages = with pkgs; [
    bind
    curl # Used by dnsmasq fetching
    sqlite
  ];
}
