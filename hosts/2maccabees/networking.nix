{ ... }:

{
	services.tailscale.enable = true;

	networking = {
		# This value is deprecated, you now set it per interface
		useDHCP = false;
		defaultGateway = "10.42.1.1";
		# 100.100.100.100 is the tailscale DNS
		nameservers = [ "100.100.100.100" "127.0.0.1" ];
		interfaces = {
			eth0.ipv4.addresses = [ {
				address = "10.42.1.2";
				prefixLength = 16;
			} ];
			wlan0.useDHCP = true;

			vlan66.ipv4.addresses = [ {
				address = "192.168.66.2";
				prefixLength = 24;
			} ];
		};

		vlans = {
			vlan66 = {
				id = 66;
				interface = "eth0";
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
}
