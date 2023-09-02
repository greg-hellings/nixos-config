{ config, pkgs, ... }:

let
	extraHosts = builtins.concatStringsSep "\n" [
		# Local hosts
		"10.42.0.1 switch"
		"10.42.1.1 router genesis genesis.thehellings.lan dns dns.thehellings.lan smart smart.thehellings.lan jellyfin jellyfin.thehellings.lan"
		#"10.42.1.2 2maccabees 2maccabees.thehellings.lan dns dns.thehellings.lan smart smart.thehellings.lan jellyfin jellyfin.thehellings.lan"
		"10.42.1.3 printer"
		"10.42.1.4 chronicles nas"
		"10.42.1.12 tv"

		# Tailscale hosts
		"100.90.74.19 jude.shire-zebra.ts.net"
		"100.99.244.92 dns.shire-zebra.ts.net 2maccabees.shire-zebra.ts.net smart.shire-zebra.ts.net jellyfin.shire-zebra.ts.net"
		"100.119.228.115 chronicles.shire-zebra.ts.net nas.shire-zebra.ts.net"
		"100.115.57.8 linode.shire-zebra.ts.net"

		# Dev hosts
		"10.42.101.1 icdm.lan wiki.icdm.lan *.icdm.lan"
	];

	extraConfig = builtins.concatStringsSep "\n" [
	];

	lanDevice = "enp1s0";

	adblockUpdate = pkgs.writeShellScriptBin "adblockUpdate" (builtins.readFile ./adblockUpdate.sh);
in
{
	# Enable the service with its own configuration
	services.dnsmasq = {
		enable = true;
		settings = {
			domain = "thehellings.lan";
			dhcp-range = [
		#		"${lanDevice},10.42.0.1,10.42.1.255,255.255.0.0,static"
				"${lanDevice},10.42.2.1,10.42.2.255,255.255.0.0,12h"
				"vlan66@${lanDevice},192.168.66.3,192.168.66.150,255.255.255.0,12h"
				"vlan67@${lanDevice},192.168.67.3,192.168.67.150,12h"
			];
			dhcp-option = [
				"${lanDevice},option:router,10.42.1.1"
				"${lanDevice},option:dns-server,10.42.1.1,1.1.1.1"
				"${lanDevice},option:domain-search,thehellings.lan,shire-zebra.ts.net"

				"vlan66@${lanDevice},option:router,192.168.66.1"
				"vlan66@${lanDevice},option:dns-server,192.168.66.1"

				"vlan67@${lanDevice},option:router,192.168.67.1"
				"vlan67@${lanDevice},option:dns-server,192.168.67.1"
			];
			dhcp-host = [
				# Static IPs for personal work
				"00:00:de:ad:be:ef,10.42.2.254"

				# Static IPs for things in the IOT range
				"98:da:c4:77:7f:4d,192.168.66.102"
				"28:87:ba:0e:ca:da,192.168.66.74"  # KS200M switch
				"8c:49:62:aa:58:60,192.168.66.108"  # Roku, HiHandsome
				"28:87:ba:0e:c9:fd,192.168.66.75"
				"4c:a1:61:05:cd:52,192.168.66.61"
				"8c:85:80:1c:f9:d1,192.168.66.104"
				"48:d6:d5:5d:81:21,192.168.66.65"  # Google Home
				"ac:84:c6:5e:4b:28,192.168.66.100"
				"d8:0d:17:19:60:62,192.168.66.112"
				"0c:80:63:41:6c:5d,192.168.66.98"  # HS200 switch
				"0c:80:63:41:74:73,192.168.66.106"
				"0c:80:63:41:6e:0f,192.168.66.90"
				"98:da:c4:20:f3:64,192.168.66.6"
				"98:da:c4:21:1b:2e,192.168.66.85"
				"98:da:c4:20:ea:db,192.168.66.107"  # HS220 switch
				"f0:03:8c:b3:b0:f6,192.168.66.55"  # Roomba
				"98:da:c4:77:80:18,192.168.66.84"
				"98:da:c4:77:82:7b,192.168.66.105"
				"e4:f0:42:61:fa:b5,192.168.66.149"  # Google Home-mini
				"b4:b0:24:9a:14:0e,192.168.66.131"
				"6c:29:90:3e:e2:02,192.168.66.66"  # wiz
				"54:af:97:83:ed:33,192.168.66.80"
				"54:af:97:c2:0f:a1,192.168.66.76"
				"b4:b0:24:9a:12:53,192.168.66.130"  # KL125
				"92:3e:11:c7:c5:be,192.168.66.109"
				"b4:b0:24:9a:02:4a,192.168.66.5"  # LD125
			];
			expand-hosts = true;
			log-dhcp = true;
			log-queries = true;
			addn-hosts = "/etc/adblock_hosts";
			# Public AdGuard DNS servers
			server = [
				"9.9.9.9"  # Quad 9
				"1.1.1.1"  # Cloudflare
				"1.0.0.1"  # Cloudflare
				"149.112.112.112"  # Quad 9
			];
		};
		extraConfig = "${extraConfig}";
	};
	environment.systemPackages = with pkgs; [
		curl
	];

	# Regularly update DNS block list
	services.cron = {
		enable = true;
		systemCronJobs = [
			"* * * * * root ${adblockUpdate} 2>&1 > /var/log/adblock.log"
		];
	};

	# Allow traffic through
	networking.firewall = {
		allowedTCPPorts = [ 53 ];
		allowedUDPPorts = [ 53 67 ];
	};

	# Custom host addition
	networking.extraHosts = "${extraHosts}";
}
