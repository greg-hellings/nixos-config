{ pkgs, ... }:

{
	imports = [
		./chat.nix
		./gnome.nix
		./firefox.nix
		./terminal.nix
	];

	home.packages = with pkgs; [
		gopls
		jellyfin-media-player
		synology-drive-client
		zoom-us
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

	programs = {
		vscode = let
			codepkg = pkgs.vscode-with-extensions.override {
				vscodeExtensions = with pkgs.vscode-extensions; [
					eamodio.gitlens
					file-icons.file-icons
					formulahendry.auto-rename-tag
					github.vscode-pull-request-github
					golang.go
					johnpapa.vscode-peacock
					jnoortheen.nix-ide
					kamikillerto.vscode-colorize
					ms-azuretools.vscode-docker
					ms-python.python
					redhat.java
					redhat.vscode-yaml
					ritwickdey.liveserver
					streetsidesoftware.code-spell-checker
					vscodevim.vim
					yzhang.markdown-all-in-one
				] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
					{
						name = "vscode-bazel";
						publisher = "BazelBuild";
						version = "0.5.0";
						sha256 = "sha256-JJQSwU3B5C2exENdNsWEcxFSgWHnImYas4t/KLsgTj4=";
					}
				];
			};
		in {
			enable = true;
			# userSettings = {
			# 	"update.channel" = "none";
			# 	"editor.renderWhitespace" = "all";
			# 	"editor.tabWidth" = "8";
			# };
			package = codepkg;
		};
	};
}
