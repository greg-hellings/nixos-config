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
		boot.kernel.sysctl = {
			"net.ipv4.ip_forward" = "1";
			"net.ipv6.conf.all.forwarding" = "1";
		};
	};
}
