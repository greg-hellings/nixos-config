{ pkgs, config, ... }:
let
	lan = "ens18";
	lanIP = "10.42.1.5";
	iot = "ens19";
	iotIP = "192.168.66.250";
	routerIP = "10.42.1.2";
	extraHosts = builtins.concatStringsSep "\n" [
		# Local hosts
		"10.42.0.1 switch switch.thehellings.lan"
		"10.42.1.1 pve1.thehellings.lan"
		"10.42.1.2 opnsense router opnsense.thehellings.lan router.thehellings.lan"
		"10.42.1.3 printer.thehellings.lan"
		"10.42.1.4 chronicles chronicles.thehellings.lan nas.thehellings.lan"
		"10.42.1.5 genesis genesis.thehellings.lan dns dns.thehellings.lan smart smart.thehellings.lan jellyfin jellyfin.thehellings.lan speedtest.thehellings.lan nixcache.thehellings.lan"
		"10.42.1.6 isaiah isaiah.thehellings.lan"
		"10.42.1.7 hosea hosea.thehellings.lan"
		"10.42.1.12 tv"

		"10.42.100.6 isaiahbmc isaiahbmc.thehellings.lan"

		# Tailscale hosts
		"100.90.74.19 jude.home"
		"100.88.91.27 dns.home"
		"100.119.228.115 chronicles.home nas.home chronicles.shire-zebra.ts.net"
		"100.115.57.8 linode.home"
		"100.88.91.27 genesis.home jellyfin.home smart.home zwave.home nixcache.home"
		"100.84.183.79 myself.home myself.shire-zebra.ts.net"
		"100.78.226.76 gitlab.home gitlab.shire-zebra.ts.net gitlab.thehellings.lan registry.thehellings.lan git.thehellings.lan"
		"100.68.203.1 hosea.home hosea.shire-zebra.ts.net"

		# Dev hosts
		"10.42.101.1 icdm.lan wiki.icdm.lan *.icdm.lan"
	];

	adblockUpdate = pkgs.writeShellScriptBin "adblockUpdate" (builtins.readFile ./adblockUpdate.sh);
	proxyPort = 3128;
	dnsPort = 53;
	dhcpPort = 67;
	dnsServers = [
		"9.9.9.9"  # Quad 9
		"1.1.1.1"  # Cloudflare
		"1.0.0.1"  # Cloudflare
		"149.112.112.112"  # Quad 9
	];
in {
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
				ipv4.addresses = [ {
					address = "${lanIP}";
					prefixLength = 16;
				} ];
			};

			"${iot}" = {
				useDHCP = false;
				ipv4.addresses = [ {
					address = "${iotIP}";
					prefixLength = 24;
				} ];
			};
		};
		firewall = {
			enable = false;
			allowedUDPPorts = [
				dhcpPort
				dnsPort
				1900  # Jellyfin auto-discovery
				7359  # Jellyfin auto-discovery
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

	fileSystems = {
		"/media" = {
			device = "10.42.1.4:/volume1/video/";
			fsType = "nfs";
			options = [ "ro" ];
		};
		"/proxy" = {
			device = "10.42.1.4:/volume1/nixpkgs/";
			fsType = "nfs";
		};
	};

	services = {
		# Video services
		jellyfin = {
			enable = true;
			openFirewall = true;
		};

		#########
		# Blind service proxy behind the walls of the VPN
		########
		_3proxy = {
			enable = true;
			services = [ {
				type = "socks";
				auth = [ "strong" ];
				bindPort = proxyPort;
				acl = [ {
					rule = "allow";
					users = [ "greg" ];
				} ];
			} ];
			#usersFile = "/run/agenix/3proxy";
			denyPrivate = false;
		};

		#########
		# dnsmasq config
		########
		dnsmasq = {
			enable = true;
			settings = {
				domain = "thehellings.lan";
				dhcp-range = [
					"${lan},10.42.2.1,10.42.2.255,255.255.0.0,12h"
					"${iot},192.168.66.3,192.168.66.150,255.255.255.0,12h"
					"vlan67@${lan},192.168.67.3,192.168.67.150,12h"
				];
				dhcp-option = [
					"${lan},option:router,${routerIP}"
					"${lan},option:dns-server,${lanIP},1.1.1.1"
					"${lan},option:domain-search,thehellings.lan"

					"${iot},option:router,192.168.66.1"
					"${iot},option:dns-server,${iotIP}"

					"vlan67@${lan},option:router,192.168.67.1"
					"vlan67@${lan},option:dns-server,192.168.67.1"
				];
				dhcp-host = [
					# Static IPs for personal work
					"00:00:de:ad:be:ef,10.42.2.254"
					"01:a8:a1:59:c7:8a:12,10.42.2.253"  # BMC management interface for isaiah

					# Static IPs for things in the IOT range
					"b4:b0:24:9a:02:4a,192.168.66.5"  # LD125
					"98:da:c4:20:f3:64,192.168.66.6"
					"54:af:97:c1:dc:b9,192.168.66.25"  # Master bedroom Kasa switch
					"f0:03:8c:b3:b0:f6,192.168.66.55"  # Roomba
					"4c:a1:61:05:cd:52,192.168.66.61"  # Rainbird
					"48:d6:d5:5d:81:21,192.168.66.65"  # Google Home
					"6c:29:90:3e:e2:02,192.168.66.66"  # wiz
					"28:87:ba:0e:ca:da,192.168.66.74"  # KS200M switch
					"28:87:ba:0e:c9:fd,192.168.66.75"
					"54:af:97:c2:0f:a1,192.168.66.76"
					"54:af:97:83:ed:33,192.168.66.80"
					"98:da:c4:77:80:18,192.168.66.84"
					"98:da:c4:21:1b:2e,192.168.66.85"
					"0c:80:63:41:6e:0f,192.168.66.90"
					"0c:80:63:41:6c:5d,192.168.66.98"  # HS200 switch
					"ac:84:c6:5e:4b:28,192.168.66.100"
					"98:da:c4:77:7f:4d,192.168.66.102"
					"8c:85:80:1c:f9:d1,192.168.66.104"
					"98:da:c4:77:82:7b,192.168.66.105"
					"0c:80:63:41:74:73,192.168.66.106"
					"98:da:c4:20:ea:db,192.168.66.107"  # HS220 switch
					"8c:49:62:aa:58:60,192.168.66.108"  # Roku, HiHandsome
					"92:3e:11:c7:c5:be,192.168.66.109"
					"d8:0d:17:19:60:62,192.168.66.112"
					"b4:b0:24:9a:12:53,192.168.66.130"  # KL125
					"b4:b0:24:9a:14:0e,192.168.66.131"
					"e4:f0:42:61:fa:b5,192.168.66.149"  # Google Home-mini
				];
				expand-hosts = true;
				log-dhcp = true;
				log-queries = true;
				no-hosts = true;  # Do not read /etc/hosts, which makes genesis resolve to 127.0.0.2
				addn-hosts = "/etc/adblock_hosts";
				hostsdir = "/etc/hosts.d/";
				server = dnsServers;
			};
		};

		# Update adblock list
		cron = {
			enable = true;
			systemCronJobs = [
				"* * * * * root ${adblockUpdate} 2>&1 > /var/log/adblock.log"
			];
		};
	};  # End of services configuration

	greg.proxies = {
		"jellyfin.home".target = "http://localhost:8096/";
	};

	services.nginx.virtualHosts."nixcache.thehellings.lan" = {
		serverName = "nixcache.thehellings.lan";
		serverAliases = [ "nixcache" "nixcache.home" ];
		root = "/proxy";
		locations = {
			"~ ^/nix-cache-info" = {
				proxyPass = "http://cache.nixos.org";
				root = "/proxy/nix-cache-info/store";
				recommendedProxySettings = false;
				extraConfig = ''
					error_log /var/log/nginx/proxy.og debug;
					proxy_store on;
					proxy_store_access user:rw group:rw all:r;
					proxy_temp_path /proxy/nix-cache-info/temp;
					proxy_pass_request_headers on;
					proxy_set_header Host "cache.nixos.org";
				'';
			};
			"~^/nar/.+$" = {
				proxyPass = "https://cache.nixos.org";
				root = "/proxy/nar/store";
				recommendedProxySettings = false;
				extraConfig = ''
					proxy_store on;
					proxy_store_access user:rw group:rw all:r;
					proxy_temp_path /proxy/nar/temp;
					proxy_pass_request_headers on;
					proxy_set_header Host "cache.nixos.org";
				'';
			};
		};
	};
	systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/proxy" ];

	environment.systemPackages = with pkgs; [
		bind
		curl  # Used by dnsmasq fetching
		sqlite
	];
}
