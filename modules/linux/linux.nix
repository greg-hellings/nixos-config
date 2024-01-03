{ config, lib, ... }:

let
	cfg = config.greg.linux;

in with lib; {
	options.greg.linux = mkEnableOption "This system is Linux";

	config = mkIf cfg {
	};
}
