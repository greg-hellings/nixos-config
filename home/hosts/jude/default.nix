{ pkgs, ... }:

{
	imports = [
		../../vscodium.nix
	];
	home.packages = with pkgs; [
		(mumble.override { pulseSupport = true; })
		logseq
	];
	greg.gui = true;
	greg.sway = false;
	greg.gnome = false;
}
