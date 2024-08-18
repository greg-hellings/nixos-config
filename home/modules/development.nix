{ config, pkgs, lib, ... }:
let
	packages = with pkgs; [
		cargo
		mariadb
		nix-update
		nixfmt-rfc-style
		nixpkgs-review
		process-compose
	];
in with lib; {
	options.greg.development = mkEnableOption "Setup necessary development packages";

	config = mkIf config.greg.development {
		home.packages = packages;
	};
}
