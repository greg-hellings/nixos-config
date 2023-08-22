{ pkgs, config, ... }:
let
	lan = "enp1s0";
	wan = "enp2s0";
	iot = "vlan66";
in {
	greg.tailscale.enable = true;

	# Really, why do I still have to force-disable this crap?
	boot.kernel.sysctl = {
		"net.ipv6.conf.${lan}.disable_ipv6" = true;
		"net.ipv6.conf.${wan}.disable_ipv6" = true;
		"net.ipv6.conf.${iot}.disable_ipv6" = true;
		"net.ipv6.conf.lo.disable_ipv6" = true;
	};

	networking = {
		enableIPv6 = false;
		networkmanager.enable = pkgs.lib.mkForce false;
		#defaultGateway = "10.42.1.1";
		# 100.100.100.100 is the tailscale DNS
		nameservers = [
			"1.1.1.1"
			#"100.100.100.100"
			"127.0.0.1"
		];
		interfaces = {
			# This is our WAN port
			"${wan}" = {
				useDHCP = true;
			};

			# This is our LAN port
			"${lan}" = {
				ipv4.addresses = [ {
					address = "10.42.1.1";
					prefixLength = 16;
				} ];
				useDHCP = false;
			};
			wlan0.useDHCP = false;

			"${iot}" = {
				useDHCP = false;
				ipv4.addresses = [ {
					address = "192.168.66.2";
					prefixLength = 24;
				} ];
			};
		};

		vlans = {
			"${iot}" = {
				id = 66;
				interface = lan;
			};
		};

		firewall.enable = false;
		# Router portion here
		nftables = let
			myvars = {
				lanInterfaces = [ lan ];
				wanInterface = wan;
				limitedLan = [ iot ];
				tcpPorts = config.networking.firewall.allowedTCPPorts;
				udpPorts = config.networking.firewall.allowedUDPPorts;
			};
		in {
			enable = true;
			rulesetFile = pkgs.template "router.nft" myvars ./nftables.nft;
		};
	};


	fileSystems."/media" = {
		device = "10.42.1.4:/volume1/video/";
		fsType = "nfs";
		options = [ "ro" ];
	};

	services.jellyfin = {
		enable = true;
		openFirewall = true;
	};

	greg.proxies = {
		"jellyfin.thehellings.lan".target = "http://localhost:8096";
		"jellyfin.me.ts".target = "http://localhost:8096";
	};

	#########
	# Blind service proxy behind the walls of the VPN
	########
	services._3proxy = {
		enable = true;
		services = [ {
			type = "socks";
			auth = [ "strong" ];
			bindPort = 3128;
			acl = [ {
				rule = "allow";
				users = [ "greg" ];
			} ];
		} ];
		#usersFile = "/run/agenix/3proxy";
		denyPrivate = false;
	};
	#age.secrets."3proxy" = {
	#	file = ../../secrets/3proxy.age;
	#	mode = "776";
	#};
	networking.firewall.allowedTCPPorts = [ 3128 ];
}
