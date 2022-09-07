{ config, lib, ... }:

let
	cfg = config.greg.linux;

in with lib; {
	options.greg.linux = mkEnableOption "This system is Linux";

	config = mkIf cfg {
		imports = [
			./automatic/users.nix
		];

		system.stateVersion = "22.05";

		# I am a fan of network manager, myself
		networking.networkmanager.enable = true;
	};
}
