{ config, lib, pkgs, ... }:

let
	cfg = config.greg.syncthing;
in with lib; {
	options.greg.syncthing = {
		enable = mkEnableOption "Setup my personal minimal configuration for Syncthing";
	};

	config = mkIf cfg.enable {
		services.syncthing = {
			enable = true;
			overrideFolders = true;
			overrideDevices = true;
			settings = {
				devices = {
					chronicles.id = "7FI6Y3M-C7YQEDI-IB345L6-RKLXMB6-AEIV57Y-3J2RCXQ-MK6QRNK-EINPXAE";
					genesis.id = "YDTH4SD-GUAC5AA-SSYWYPZ-YMJW5LK-LE7PZKJ-GV2UJFZ-CU7LZAD-GTYWCQK";
					linode.id = "IJMMXPR-WNALZBD-FMJH5W5-WV7XGJY-HLJTKGT-5TKHJIH-75LT56D-UUZCYQE";
				};
				options = {
					urAccepted = -1;
				};
			};
		};
	};
}
