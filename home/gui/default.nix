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

	# An alternative editor to vim, when I need it for some things
	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		extensions = with pkgs.vscode-extensions; [
			golang.go
			ms-python.python
			ms-pyright.pyright
			vscjava.vscode-java-test
			vscjava.vscode-java-dependency
			vscjava.vscode-java-debug
			vscodevim.vim
		];
	};

	# These packages are Linux only
	home.packages = with pkgs; ( excludes ["x86_64-darwin" "aarch64-darwin"]
	[
		cdrtools
		vlc
		x265
	]) ++

	# x86_64-linux only
	( excludes ["x86_64-darwin" "aarch64-darwin" "aarch64-linux"]
	[
		bitwarden
		endeavour
		gnucash
		jellyfin-media-player
		libreoffice
		logseq
		nextcloud-client
	]) ++

	# Items that are not supported on ARM/Linux
	( excludes ["aarch64-linux"]
	[
		onlyoffice-bin
		synology-drive-client
		zoom-us
	]);
}
