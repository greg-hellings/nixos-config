{ ... }:

let
	syncs = [
		"nas"
		"dns"
		"linode"
	];
in
{
	services.syncthing = {
		enable = true;
		user = "greg";
		group = "users";
		dataDir = "/home/greg/sync";
		devices = {
			nas = {
				addresses = [
					"tcp://nas.thehellings.lan:22000"
					"tcp://chronicles.greg-hellings.gmail.com.beta.tailscale.net:22000"
				];
				id = "74JUTZG-77EPGO3-FEYCL2P-CHDWP5G-6EXWZVB-XTAH6O5-TUXCVY2-QNRHSQ4";
			};
			dns = {
				addresses = [
					"tcp://dns.thehellings.lan:22000"
					"tcp://2maccabees.greg-hellings.gmail.com.beta.tailscale.net:22000"
				];
				id = "C4XJCH7-3ZNW6XZ-R5DB2EU-OEGVVT2-WPHQAG7-UDWER36-6NO5KZR-4MN5VAK";
			};
			linode = {
				addresses = [
					"tcp://linode.thehellings.com:22000"
				];
				id = "ROZPUG5-G4IAXYA-JNRQXRD-5PFU2BQ-WVJTOGZ-DFMGJ5E-Q4IGXCJ-JHSNDQ6";
			};
		};
		folders = {
			"mkrvy-tc6x9" = {
				path = "/home/greg/drive";
				enable = true;
				devices = syncs;
			};
		};
	};
}
