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
		dconf2nix
		vlc
		x265
	] ++

	# Items that cannot be outside of x86_64-linux at all
	( excludes ["x86_64-darwin" "aarch64-darwin" "aarch64-linux"]
	[
		endeavour
		jellyfin-media-player
		libreoffice
		logseq
		nextcloud-client
	]) ++

	# Items that are not supported on ARM/Linux
	( excludes ["aarch64-linux"]
	[
		bitwarden
		onlyoffice-bin
		zoom-us
	]);
}
