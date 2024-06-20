{ config, ... }:

let
	publicIp = (builtins.elemAt config.networking.interfaces.enp38s0.ipv4.addresses 0).address;
	sanIp = (builtins.elemAt config.networking.interfaces.enp39s0.ipv4.addresses 0).address;
	vip = (builtins.elemAt config.networking.interfaces.enp38s0.ipv4.addresses 1).address;
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
				id = 2;
				uuid = "73424b68-210b-415f-800f-8767babea625";
				blockDevice = "/dev/disk/by-id/ata-ST12000NM0558_ZHZ5WM4L";
				blockDeviceUdevRuleMatcher = ''KERNEL=="sdb"'';
				clusterAddress = sanIp;
			};
		};
	};
}
