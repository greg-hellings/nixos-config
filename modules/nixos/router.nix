{ config, lib, pkgs, ... }:

let
  names = mylist: (lib.strings.concatMapStringsSep "," (x: ''"${x}"'') mylist);
  # Pass the names of the wan/lan ports
  nftConfig =
    { wan
    , lan
    , limitedLan ? [ ]
    , openPorts ? [ "ssh" "67" "53" ]
    , # ssh, dhcpd, dns
      openUDPPorts ? [ "67" "53" ] # dhcpd, dns
    }:
    let
      lanList = names lan;
      allLan = names (lan ++ limitedLan);
      wanName = names wan;
      portsString = lib.strings.concatMapStringsSep "\n" (x: "iifname { ${lanList}, \"tailscale0\" } tcp dport ${toString x} accept") openPorts;
      udpPortsString = lib.strings.concatMapStringsSep "\n" (x: "iifname { ${lanList}, \"tailscale0\" } udp dport ${toString x} accept") openUDPPorts;
    in
    lib.strings.concatStringsSep "\n" [
      "table ip filter {"
      "	chain output {"
      "		type filter hook output priority 100; policy accept;"
      "	}"

      "	chain input {"
      "		type filter hook input priority 0; policy drop;"

      "		iifname lo accept"
      portsString
      udpPortsString
      "		iifname { ${lanList} } accept comment \"Allows LAN traffic and outgoing\""
      "		iifname { ${wanName} } ct state { established, related } accept comment \"Allows existing connections\""
      "		iifname { ${wanName} } icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment \"Allow some ICMP traffic\""
      "		iifname { ${wanName} } counter drop comment \"Drop other incoming traffic, and count how much\""
      "	}"
      "	chain forward {"
      "		type filter hook forward priority 0; policy drop;"
      "		iifname { ${allLan} } oifname { ${wanName} } accept comment \"Forward LAN to WAN\""
      "		iifname { ${wanName} } oifname { ${allLan} } ct state established, related accept comment \"Allow incoming established traffic\""
      "	}"
      "}"

      "table ip nat {"
      "	chain postrouting {"
      "		type nat hook postrouting priority 100; policy accept;"
      "		oifname { ${wanName} } masquerade"
      "	}"
      "}"

      "table ip6 filter {"
      "	chain input {"
      "		type filter hook input priority 0; policy drop;"
      "	}"
      "	chain forward {"
      "		type filter hook forward priority 0; policy drop;"
      "	}"
      "}"
    ];
  cfg = config.greg.router;

in
with lib; {
  options.greg.router = {
    enable = mkEnableOption "Enable NFTables and routing";
    wan = mkOption {
      type = (types.listOf types.str);
      description = "The name of the network interface that is the WAN connection";
    };
    lan = mkOption {
      type = (types.listOf types.str);
      description = "A list of all network interfaces that are considered LAN connections";
    };
    limited = mkOption {
      type = (types.listOf types.str);
      description = "A list of limited access LAN connections - such as IOT connections and similar.";
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    networking.nftables = {
      enable = true;
      ruleset = (nftConfig {
        inherit (cfg) lan wan;
        openPorts = config.networking.firewall.allowedTCPPorts;
        openUDPPorts = config.networking.firewall.allowedUDPPorts;
      });
    };

    environment.systemPackages = [
      pkgs.pciutils
      pkgs.tcpdump
    ];
  };
}
