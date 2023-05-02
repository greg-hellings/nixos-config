{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./firefox.nix
	];

	home.packages = with pkgs; [
		cdrtools
		endeavour
		ffmpeg
		gnucash
		handbrake
		libtheora
		logseq
		vlc
		x265
	] ++ ( if ( pkgs.system != "x86_64-darwin" && pkgs.system != "aarch64-linux" ) then
		[
			jellyfin-media-player
			libreoffice
			nextcloud-client
		] else []
	) ++ ( if ( pkgs.system != "aarch64-linux" ) then
		[
			bitwarden
			onlyoffice-bin
			synology-drive-client
			zoom-us
		] else []
	);
}
