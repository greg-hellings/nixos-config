{ pkgs, ... }:

{
	imports = [
		../../vscodium.nix
	];
	home.packages = [
		(pkgs.mumble.override { pulseSupport = true; })
	];
}
