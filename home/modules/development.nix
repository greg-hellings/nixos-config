{ config, pkgs, lib, ... }:
let
	packages = with pkgs; [
		cargo
		nixfmt-rfc-style
		nixpkgs-review
	];
in with lib; {
	options.greg.development = mkEnableOption "Setup necessary development packages";

	config = mkIf config.greg.development {
		home.packages = packages;
	};
}
