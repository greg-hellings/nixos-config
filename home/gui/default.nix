{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./gnome.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		bazel
		bazel-buildtools
		bitwarden
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
		onlyoffice-bin
		synology-drive-client
		vlc
		x265
		zoom-us
	] ++ ( if pkgs.system != "x86_64-darwin" then
		[
			jellyfin-media-player
			nextcloud-client
		] else []
	);
}
