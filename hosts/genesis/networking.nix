{ ... }:

{
	greg.tailscale.enable = true;

	networking = {
		enableIPv6 = false;
		#defaultGateway = "10.42.1.1";
		# 100.100.100.100 is the tailscale DNS
		nameservers = [
			"1.1.1.1"
			#"100.100.100.100"
			"127.0.0.1"
		];
		interfaces = {
			# This is our WAN port
			enp2s0 = {
				useDHCP = true;
				name = "wan";
			};

			# This is our LAN port
			enp1s0.ipv4.addresses = [ {
				address = "10.43.1.1";
				prefixLength = 16;
			} ];
			wlan0.useDHCP = false;

			vlan66.ipv4.addresses = [ {
				address = "192.168.66.2";
				prefixLength = 24;
			} ];
		};

		vlans = {
			vlan66 = {
				id = 66;
				interface = "enp2s0";
			};
		};
	};

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

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
