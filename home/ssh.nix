{ lib, ... }:

{
	programs.ssh = {
		enable = true;
		serverAliveInterval = 60;

		matchBlocks =
		let
			nas = { user = "admin"; };
			owned = { user = "greg"; };
		in {
			"10.42.1.4" = lib.hm.dag.entryBefore ["10.42.*"] nas;
			nas = nas;
			"nas.thehellings.lan" = nas;
			"nas.greg-hellings.gmail.com.beta.tailscale.net" = nas;
			chronicles = nas;
			"chronicles.thehellings.lan" = lib.hm.dag.entryBefore [ "*.thehellings.lan"] nas;

			gh = { user = "git"; hostname = "github.com"; };

			"*.thehellings.lan" = owned;
			"10.42.*" = owned;

			"host.crosswire.org crosswire" = {
				hostname = "host.crosswire.org";
				user = "ghellings";
			};

			fedpeople = {
				hostname = "fedorapeople.org";
				user = "greghellings";
			};

			"src.fedoraproject.org pkgs.fedoraproject.org" = {
				user = "greghellings";
			};

			"127.*".extraOptions = {
				PubkeyAcceptedAlgorithms = "+ssh-rsa";
				HostkeyAlgorithms = "+ssh-rsa";
			};
		};
	};

	home.file = {
		".ssh/id_rsa".text = builtins.readFile ./ssh/id_rsa;
		".ssh/id_rsa.pub".text = builtins.readFile ./ssh/id_rsa.pub;
	};
}
