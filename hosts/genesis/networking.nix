{ pkgs, config, ... }:
let
	lan = "ens18";
	iot = "ens19";
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
		defaultGateway = "10.42.1.1";
		nameservers = [
			"1.1.1.1"
			"1.0.0.1"
			"127.0.0.1"
		];
		interfaces = {
			# This is our LAN port
			"${lan}" = {
				useDHCP = false;
				ipv4.addresses = [ {
					address = "10.42.1.5";
					prefixLength = 16;
				} ];
			};

			"${iot}" = {
				useDHCP = false;
				ipv4.addresses = [ {
					address = "192.168.66.250";
					prefixLength = 24;
				} ];
			};
		};
		firewall.enable = true;
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
	# Used for service auto-disocvery
	networking.firewall.allowedUDPPorts = [ 1900 7359 ];

	greg.proxies = {
		"jellyfin.thehellings.lan".target = "http://localhost:8096";
		"jellyfin.shire-zebra.ts.net" = {
			target = "http://localhost:8096";
			genAliases = false;
		};
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
