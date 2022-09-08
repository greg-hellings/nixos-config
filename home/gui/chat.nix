{ pkgs, lib, ... }:

{
	home.packages = with pkgs; ( if ( lib.hasSuffix "-darwin" pkgs.system) then
		[] else
	[
		element-desktop
	]);
}
