{
  lan,
  iot,
  lanIP,
  routerIP,
}:
{
  enable = false;
  settings = {
    control-sockets = [
      {
        socket-type = "unix";
        socket-name = "/run/kea/dhcp4-control.sock";
      }
    ];
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
        id = 1;
        subnet = "10.42.0.0/16";
        pools = [ { pool = "10.42.2.0 - 10.42.3.255"; } ];
        interface = lan;
        # https://kea.readthedocs.io/en/kea-2.6.1/arm/dhcp4-srv.html#dhcp4-std-options-list
        option-data = [
          {
            name = "domain-name-servers";
            data = "${lanIP}";
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
        reservations-global = false;
        reservations-in-subnet = true;
        reservations-out-of-pool = false;
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
            #ip-address = "10.42.2.253";
            ip-address = "10.42.100.6";
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
          {
            hw-address = "b4:2e:99:aa:22:3c"; # jeremiah
            ip-address = "10.42.1.8";
          }
          {
            hw-address = "c8:5e:a9:54:9e:c6"; # IVR laptop Wi-Fi
            ip-address = "10.42.1.9";
          }
          {
            hw-address = "c8:4b:d6:ca:20:8f";
            ip-address = "10.42.1.10"; # The monitor
          }
          {
            hw-address = "04:7c:16:d5:60:6f";
            ip-address = "10.42.1.13"; # Zeke - but straight in the motherboard
          }
          {
            hw-address = "24:8a:07:8c:8c:b6";
            ip-address = "10.42.1.14"; # nas1 25G port
          }

          ########################################
          #             VM servers               #
          ########################################

          {
            hw-address = "52:54:00:2a:74:2f";
            ip-address = "10.42.4.1"; # Dendrite
          }
          {
            hw-address = "BC:24:11:8F:91:77";
            ip-address = "10.42.4.2"; # Jellyfin
          }
          {
            hw-address = "BC:24:11:6E:0C:40";
            ip-address = "10.42.4.3"; # Gitlab
          }
        ];
      }
      {
        id = 66;
        subnet = "192.168.66.0/24";
        pools = [ { pool = "192.168.66.2 - 192.168.66.254"; } ];
        interface = iot;
        option-data = [
          {
            name = "domain-name-servers";
            data = "1.0.0.1,1.1.1.1";
          }
          {
            name = "routers";
            data = "192.168.66.1";
          }
        ];
        reservations = [
          {
            hw-address = "d0:17:69:c6:09:49"; # Daikin
            ip-address = "192.168.66.10";
          }
        ];
      }
    ];

  };
}
