{ config, lib, ... }:

let
	cfg = config.greg.home;

in with lib;
{
	options.greg.home = mkOption {
		type = types.bool;
		default = true;
		description = "Sets the device up to be part of my home network";
	};

	config = mkIf cfg {
		time.timeZone = "America/Chicago";
		networking.domain = "thehellings.lan";
	};
}
