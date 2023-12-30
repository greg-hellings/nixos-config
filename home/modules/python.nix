{ config, pkgs, lib, ... }:
{
	options.greg.pypackage = lib.mkOption {
		description = "Enable Gnome support and settings";
		type = lib.types.package;
		default = pkgs.gregpy;
	};

	config.home.packages = [ config.greg.pypackage ];
}
