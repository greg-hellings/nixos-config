{ config, ... }:

{
	networking = {
		# This value is deprecated, you now set it per interface
		useDHCP = false;
		defaultGateway = "10.42.1.1";
		nameservers = [ "127.0.0.1" ];
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

			vlan67.ipv4.addresses = [ {
				address = "192.168.67.2";
				prefixLength = 24;
			} ];
		};

		vlans = {
			vlan66 = {
				id = 66;
				interface = "eth0";
			};
			vlan67 = {
				id = 67;
				interface = "eth0";
			};
		};
	};

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;
}
