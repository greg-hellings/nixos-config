{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		bitwarden
		handbrake
		onlyoffice-bin
		synology-drive-client
		vlc
	];
}
