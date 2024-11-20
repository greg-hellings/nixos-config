{
  lan,
  iot,
  lanIP,
  iotIP,
  routerIP,
}:
{
  enable = true;
  settings = {
    valid-lifetime = 43200; # 12 hours, in seconds
    renew-timer = 1000;
    rebind-timer = 2000;
    interfaces-config.interfaces = [
      lan
      iot
    ];
    lease-database = {
      type = "memfile";
      persist = true;
      name = "/var/lib/kea/dhcp4.leases";
    };
    subnet4 = [
      {
        subnet = "10.42.0.0/16";
        pools = [ { pool = "10.42.2.0 - 10.42.3.255"; } ];
        interface = lan;
        # https://kea.readthedocs.io/en/kea-2.6.1/arm/dhcp4-srv.html#dhcp4-std-options-list
        option-data = [
          {
            name = "domain-name-servers";
            data = "${lanIP},1.1.1.1";
          }
          {
            name = "routers";
            data = routerIP;
          }
          {
            name = "domain-search";
            data = "home,thehellings.lan";
          }
          {
            name = "lpr-servers";
            data = "10.42.1.3";
          }
          {
            name = "domain-name";
            data = "thehellings.lan";
          }
        ];
      }
      {
        subnet = "192.168.66.0/24";
        pools = [ { pool = "192.168.66.2 - 192.168.66.254"; } ];
        interface = iot;
        option-data = [
          {
            name = "domain-name-servers";
            data = iotIP;
          }
          {
            name = "routers";
            data = "192.168.67.1";
          }
        ];
      }
    ];

    reservations = [
      # Static IPs for personal work
      {
        hw-address = "00:23:24:72:64:32"; # Joel
        ip-address = "10.42.0.4";
      }
      {
        hw-address = "2a:5d:23:10:4e:22"; # SAN Switch
        ip-address = "10.42.0.5";
      }
      {
        hw-address = "00:00:de:ad:be:ef"; # deadbeef
        ip-address = "10.42.2.254";
      }
      {
        hw-address = "01:a8:a1:59:c7:8a:12"; # BMC management interface for isaiah
        ip-address = "10.42.2.253";
      }
      {
        hw-address = "7c:83:34:b9:ee:ec"; # PVE1
        ip-address = "10.42.1.1";
      }
      {
        hw-address = "74:ee:2a:66:b3:51"; # printer
        ip-address = "10.42.1.3";
      }
      {
        hw-address = "00:11:32:c6:7c:81"; # chronicles
        ip-address = "10.42.1.4";
      }
      {
        hw-address = "6a:86:56:45:0b:b1"; # Genesis
        ip-address = "10.42.1.5";
      }
      {
        hw-address = "a8:a1:59:c7:20:44"; # isaiah
        ip-address = "10.42.1.6";
      }
      #{
      #  hw-address = ""; # hosea
      #  ip-address = "10.42.1.7";
      #}
      #{
      #  hw-address = ""; # jeremiah
      #  ip-address = "10.42.1.8";
      #}
      {
        hw-address = "c8:5e:a9:54:9e:c6"; # IVR laptop Wi-Fi
        ip-address = "10.42.1.9";
      }

      {
        hw-address = "52:54:00:2a:74:2f";
        ip-address = "10.43.4.1";
      }

      ########################################
      #             IOT devices              #
      ########################################

      # Static IPs for things in the IOT range
      {
        hw-address = "b4:b0:24:9a:02:4a";
        ip-address = "192.168.66.5";
      } # LD125
      {
        hw-address = "f0:03:8c:b3:b0:f6";
        ip-address = "192.168.66.55";
      } # Roomba
      {
        hw-address = "4c:a1:61:05:cd:52";
        ip-address = "192.168.66.61";
      } # Rainbird
      {
        hw-address = "48:d6:d5:5d:81:21";
        ip-address = "192.168.66.65";
      } # Google Home
      {
        hw-address = "28:87:ba:0e:ca:da";
        ip-address = "192.168.66.74";
      }
      {
        hw-address = "54:af:97:83:ed:33";
        ip-address = "192.168.66.80";
      }
      {
        hw-address = "ac:84:c6:5e:4b:28";
        ip-address = "192.168.66.100";
      }
      {
        hw-address = "8c:85:80:1c:f9:d1";
        ip-address = "192.168.66.104";
      }
      {
        hw-address = "8c:49:62:aa:58:60";
        ip-address = "192.168.66.108";
      } # Roku, HiHandsome
      {
        hw-address = "92:3e:11:c7:c5:be";
        ip-address = "192.168.66.109";
      }
      {
        hw-address = "d8:0d:17:19:60:62";
        ip-address = "192.168.66.112";
      }
      {
        hw-address = "b4:b0:24:9a:12:53";
        ip-address = "192.168.66.130";
      } # KL125
      {
        hw-address = "b4:b0:24:9a:14:0e";
        ip-address = "192.168.66.131";
      }
      {
        hw-address = "e4:f0:42:61:fa:b5";
        ip-address = "192.168.66.149";
      } # Google Home-mini
    ];
  };
}
