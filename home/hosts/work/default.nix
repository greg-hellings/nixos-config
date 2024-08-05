{ pkgs, ... }:

{
	greg.vscodium.enable = true;

	home.packages = with pkgs; [
		brew
	];
}
