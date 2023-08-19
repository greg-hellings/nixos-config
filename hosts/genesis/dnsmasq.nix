{ config, pkgs, ... }:

let
	extraHosts = builtins.concatStringsSep "\n" [
		# Local hosts
		"10.42.0.1 switch"
		"10.42.1.1 router"
		"10.42.1.2 2maccabees 2maccabees.thehellings.lan dns dns.thehellings.lan smart smart.thehellings.lan jellyfin jellyfin.thehellings.lan"
		"10.42.1.3 printer"
		"10.42.1.4 chronicles nas"
		"10.42.1.12 tv"

		# Tailscale hosts
		"100.90.74.19 jude.me.ts"
		"100.99.244.92 dns.me.ts 2maccabees.me.ts smart.me.ts jellyfin.me.ts"
		"100.119.228.115 chronicles.me.ts nas.me.ts"
		"100.115.57.8 linode.me.ts"

		# Dev hosts
		"10.42.101.1 icdm.lan wiki.icdm.lan *.icdm.lan"
	];

	extraConfig = builtins.concatStringsSep "\n" [
	];

	lanDevice = "enp1s0";
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
				"${lanDevice},option:dns-server,10.42.1.2,1.1.1.1"
				"${lanDevice},option:domain-search,thehellings.lan"

				"vlan66@${lanDevice},option:router,192.168.66.1"
				"vlan66@${lanDevice},option:dns-server,192.168.66.2"

				"vlan67@${lanDevice},option:router,192.168.67.1"
				"vlan67@${lanDevice},option:dns-server,192.168.67.2"
			];
			expand-hosts = true;
			log-dhcp = true;
			log-queries = true;
			addn-hosts = "/etc/adblock_hosts";
			# Public AdGuard DNS servers
			server = [
				"94.140.14.14"
				"94.140.15.15"
			];
		};
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
