{ pkgs, lib, ... }:

let
	darwinPkgs = [];
	x86Pkgs = with pkgs; [
		element-desktop
		slack
	];
	armPkgs = with pkgs; [
		element-desktop
	];
in {
	home.packages = ( if ( pkgs.stdenv.hostPlatform.isDarwin ) then darwinPkgs else
		( if ( lib.hasPrefix "aarch64" pkgs.system ) then armPkgs else
			( if ( lib.hasPrefix "x86_64" pkgs.system ) then x86Pkgs else [] )
		)
	);
}
