{ config, lib, ... }:

let
	cfg = config.greg.darwin;

in with lib; {
	options = {
		greg.darwin = mkEnableOption "This system is Darwin";
	};

	config = mkIf cfg {
		system.stateVersion = 4;
		programs = {
			zsh.enable = true;
			bash.enable = true;
		};
	};
}
