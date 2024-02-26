{ pkgs, ... }:

{
	imports = [
		../../vscodium.nix
	];
	home.packages = with pkgs; [
		(mumble.override { pulseSupport = true; })
		fluffychat
		logseq
	];
	greg.gui = true;
	greg.sway = true;
}
