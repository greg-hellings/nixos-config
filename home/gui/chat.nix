{ pkgs, lib, ... }:

let
	darwinPkgs = [];
	x86Pkgs = with pkgs; [
		element-desktop
		slack
	];
	archPkgs = with pkgs; [
		element-desktop
	];
in {
	home.packages = ( if ( pkgs.stdenv.hostPlatform.isDarwin ) then darwinPkgs else 
		( if ( lib.hasPrefix "aarch64" pkgs.system ) then archPkgs else 
			( if ( lib.hasPrefix "x86_64" pkgs.system ) then x86Pkgs else [] )
		)
	);
}
