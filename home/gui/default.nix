{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./gnome.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		synology-drive-client
	] ++ ( if pkgs.system == "x86_64-darwin" then
		[
			libreoffice-bin
		] else
		[
			bitwarden
			gnucash
			handbrake
			nextcloud-client
			onlyoffice-bin
			vlc
		]
	);
}
