{ config, ... }:

let
	publicIp = (builtins.elemAt config.networking.interfaces.enp68s0.ipv4.addresses 0).address;
	sanIp = (builtins.elemAt config.networking.interfaces.enp67s0.ipv4.addresses 0).address;
	vip = (builtins.elemAt config.networking.interfaces.enp68s0.ipv4.addresses 1).address;
	hostname = config.networking.hostName;
	baseConfig = import ../../ceph/home.nix;
in {
	services.ceph-benaco = baseConfig // {
		enable = true;
		monitor = {
			enable = true;
			initialKeyring = ../../secrets/home.mon.keyring;
			nodeName = hostname;
			bindAddr = publicIp;
			advertisedPublicAddr = vip;
		};
		osdBindAddr = publicIp;
		osdAdvertisedPublicAddr = publicIp;
		osds = {
			osd1 = {
				enable = true;
				bootstrapKeyring = ../../secrets/home.osd-bootstrap.keyring;
				id = 1;
				uuid = "c13bd2b1-cfc7-4966-8da5-d92356e87e06";
				blockDevice = "/dev/sda";
				blockDeviceUdevRuleMatcher = ''KERNEL=="sda"'';
				clusterAddress = sanIp;
			};
		};
	};
}
