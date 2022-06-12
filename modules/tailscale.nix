{ lib, config, ... }:

let
	cfg = config.greg.tailscale;
in {
	options = {
		greg.tailscale.enable = lib.mkEnableOption "Enable Tailscale";
	};

	config = lib.mkIf cfg.enable {
		services.tailscale.enable = true;
		networking.firewall.checkReversePath = "loose";
	};
}
