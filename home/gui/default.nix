{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		onlyoffice-bin
	];
}
