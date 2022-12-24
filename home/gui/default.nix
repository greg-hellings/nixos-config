{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./firefox.nix
	];

	home.packages = with pkgs; [
		bazel
		bazel-buildtools
		cargo # Rustc
		cdrtools
		ffmpeg
		gcc
		gnucash
		go
		gopls
		handbrake
		jdk11
		libtheora
		vlc
		x265
	] ++ ( if ( pkgs.system != "x86_64-darwin" && pkgs.system != "aarch64-linux" ) then
		[
			jellyfin-media-player
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
