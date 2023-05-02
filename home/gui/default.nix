{ pkgs, ... }:

let
	excludes = systems: opts: (
		if ( builtins.all (x: pkgs.system != x) systems ) then opts else []
	);

in
{
	imports = [
		./chat.nix
		./firefox.nix
	];

	home.packages = with pkgs; [
		cdrtools
		ffmpeg
		gnucash
		handbrake
		libtheora
		vlc
		x265
	] ++
	( excludes ["x86_64-darwin" "aarch64-darwin" "aarch64-linux"]
	[
		endeavour
		jellyfin-media-player
		libreoffice
		logseq
		nextcloud-client
	]) ++
	( excludes ["aarch64-linux"]
	[
		bitwarden
		onlyoffice-bin
		synology-drive-client
		zoom-us
	]);
}
