{ config, pkgs, ... }:

let
	extraHosts = builtins.concatStringsSep "\n" [
		"10.42.0.1 switch"
		"10.42.1.1 router"
		"10.42.1.2 2maccabees 2maccabees.thehellings.lan dns dns.thehellings.lan smart smart.thehellings.lan"
		"100.99.244.92 dns.me.ts 2maccabees.me.ts smart.me.ts"
		"10.42.1.3 printer"
		"10.42.1.4 chronicles nas"
		"100.119.228.115 nas.me.ts"
		"10.42.1.12 tv"
		"100.90.74.19 jude.me.ts"

		"10.42.101.1 icdm.lan wiki.icdm.lan *.icdm.lan"
	];

	extraConfig = builtins.concatStringsSep "\n" [
		"expand-hosts"
		"domain=thehellings.lan"
		"log-dhcp"
		"log-queries"
		"addn-hosts=/etc/adblock_hosts"

#		"dhcp-range=eth0,10.42.0.1,10.42.1.255,255.255.0.0,static"
		"dhcp-range=eth0,10.42.2.1,10.42.2.255,255.255.0.0,12h"
		"dhcp-option=eth0,option:router,10.42.1.1"
		"dhcp-option=eth0,option:dns-server,10.42.1.2"
		"dhcp-option=eth0,option:domain-search,thehellings.lan"

		"dhcp-range=vlan66@eth0,192.168.66.3,192.168.66.150,255.255.255.0,12h"
		"dhcp-option=vlan66@eth0,option:router,192.168.66.1"
		"dhcp-option=vlan66@eth0,option:dns-server,192.168.66.2"

		"dhcp-range=vlan67@eth0,192.168.67.3,192.168.67.150,12h"
		"dhcp-option=vlan67@eth0,option:router,192.168.67.1"
		"dhcp-option=vlan67@eth0,option:dns-server,192.168.67.2"
	];
in
{
	# Enable the service with its own configuration
	services.dnsmasq = {
		enable = true;
		# Public AdGuard DNS servers
		servers = [
			"94.140.14.14"
			"94.140.15.15"
		];
		extraConfig = "${extraConfig}";
	};
	environment.systemPackages = [ pkgs.curl ];

	# Regularly update DNS block list
	services.cron = {
		enable = true;
		systemCronJobs = [
			"* * * * * root ( ${pkgs.curl}/bin/curl -s https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sed '1,33d' > /etc/adblock_hosts && systemctl restart dnsmasq ) 2>&1 > /var/log/adblock.log"
		];
	};

	# Allow traffic through
	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 53 ];
		allowedUDPPorts = [ 53 67 ];
	};

	# Custom host addition
	networking.extraHosts = "${extraHosts}";
}
