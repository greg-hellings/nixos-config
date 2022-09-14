{ config, lib, pkgs, ... }:

let
	cfg = config.greg.xprograms;

in with lib; {
	options = {
		greg.xprograms.enable = mkEnableOption "Install my favorite XPrograms";
	};

	config = mkIf cfg.enable {
		environment.systemPackages = with pkgs; [
			keepassxc
			nextcloud-client
		];
	};
}
