{...}:

{
	# If we have to do proxying in Bayonnais, we can start to work on that here
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
	networking = {
		hostName = "icdm-root";
		useDHCP = false;
		defaultGateway = "10.42.1.1";
		nameservers = [ "100.100.100.100" "10.42.1.2" ];
		enableIPv6 = false;

		interfaces = {
			eno1.ipv4.addresses = [ {
				address = "10.42.101.1";
				prefixLength = 16;
			} ];
		};
	};
}
