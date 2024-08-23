{ config, ... }:

let
	ip = "100.68.203.1";
in {
	nix-bitcoin = {
		generateSecrets = true;
		operator = {
			enable = true;
			name = "greg";
		};
		useVersionLockedPkgs = true;  # Use the exact versions of packages from upstream
	};

	networking.firewall.allowedTCPPorts = with config.services; [
		bitcoind.port
		bitcoind.rpc.port
		mempool.frontend.port
	];

	services = {
		bitcoind = {
			enable = true;
			address = "0.0.0.0";
			dataDir = "/chain/bitcoind";
			listen = true;
			rpc = {
				address = ip;
				allowip = [
					"100.1.1.1/8"
				];
			};
		};
		clightning.enable = true;
		electrs = {
			enable = true;
			address = ip;
		};
		mempool = {
			enable = true;
			frontend = {
				enable = true;
				address = ip;
			};
		};
	};
}
