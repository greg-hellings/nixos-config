{ config, pkgs, lib, ... }:
let
	packages = with pkgs; [
		cargo
		mariadb
		nix-eval-jobs
		nix-fast-build
		nix-output-monitor
		nix-update
		nixfmt-rfc-style
		nixpkgs-review
		nodejs
		process-compose
	];
in with lib; {
	options.greg.development = mkEnableOption "Setup necessary development packages";

	config = mkIf config.greg.development {
		home.packages = packages;
	};
}
