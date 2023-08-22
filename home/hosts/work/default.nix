{ pkgs, ... }:

{
	home.packages = with pkgs; [
		brew
	];
}
