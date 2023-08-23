{ pkgs, ... }:

{
	imports = [
		../../vscodium.nix
	];

	home.packages = with pkgs; [
		brew
	];
}
