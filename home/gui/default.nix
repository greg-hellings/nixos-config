{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		bitwarden
		gnucash
		handbrake
		onlyoffice-bin
		synology-drive-client
		vlc
	];
}
