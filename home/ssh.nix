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
		};
	};
}
