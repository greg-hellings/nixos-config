{ pkgs, ... }:

{
	imports = [
		./chat.nix
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
			onlyoffice-bin
			vlc
		]
	);
}
