{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		bitwarden
		onlyoffice-bin
		synology-drive-client
		vlc
	];
}
