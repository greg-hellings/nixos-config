{ pkgs, ... }:
let
  lan = "ens18";
  lanIP = "10.42.1.5";
  iot = "ens19";
  iotIP = "192.168.66.250";
  routerIP = "10.42.1.2";
  extraHosts = builtins.readFile ./net/hosts;

  adblockUpdate = pkgs.writeShellScriptBin "adblockUpdate" (builtins.readFile ./adblockUpdate.sh);
  proxyPort = 3128;
  dnsPort = 53;
  dhcpPort = 67;
  dnsServers = [
    "9.9.9.9" # Quad 9
    "1.1.1.1" # Cloudflare
    "1.0.0.1" # Cloudflare
    "149.112.112.112" # Quad 9
  ];
in
{
  greg.tailscale.enable = true;

  # Really, why do I still have to force-disable this crap?
  boot.kernel.sysctl = {
    "net.ipv6.conf.${lan}.disable_ipv6" = true;
    "net.ipv6.conf.${iot}.disable_ipv6" = true;
    "net.ipv6.conf.lo.disable_ipv6" = true;
  };

  networking = {
    enableIPv6 = false;
    networkmanager.enable = pkgs.lib.mkForce false;
    defaultGateway = routerIP;
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
    # Blind service proxy behind the walls of the VPN
    ########
    _3proxy = {
      enable = true;
      services = [
        {
          type = "socks";
          auth = [ "strong" ];
          bindPort = proxyPort;
          acl = [
            {
              rule = "allow";
              users = [ "greg" ];
            }
          ];
        }
      ];
      #usersFile = "/run/agenix/3proxy";
      denyPrivate = false;
    };

    kea.dhcp4 = (
      import ./networking/dhcp.nix {
        inherit
          iot
          iotIP
          lan
          lanIP
          routerIP
          ;
      }
    );

    #########
    # dnsmasq config
    ########
    dnsmasq = {
      enable = true;
      settings = {
        domain = "thehellings.lan";
        expand-hosts = true;
        log-queries = true;
        no-hosts = true; # Do not read /etc/hosts, which makes genesis resolve to 127.0.0.2
        addn-hosts = "/etc/adblock_hosts";
        hostsdir = "/etc/hosts.d/";
        server = dnsServers;
      };
    };

    # Update adblock list
    cron = {
      enable = true;
      systemCronJobs = [ "* * * * * root ${adblockUpdate} 2>&1 > /var/log/adblock.log" ];
    };
  }; # End of services configuration

  environment.systemPackages = with pkgs; [
    bind
    curl # Used by dnsmasq fetching
    sqlite
  ];
}
