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

	programs = {
		vscode = let
			codepkg = pkgs.vscode-with-extensions.override {
				vscodeExtensions = with pkgs.vscode-extensions; [
					coenraads.bracket-pair-colorizer-2
					eamodio.gitlens
					formulahendry.auto-rename-tag
					golang.go
					jnoortheen.nix-ide
					ms-azuretools.vscode-docker
					ms-python.python
					redhat.vscode-yaml
					yzhang.markdown-all-in-one
				];
			};
		in {
			enable = true;
			userSettings = {
				"update.channel" = "none";
				"editor.renderWhitespace" = "all";
				"editor.tabWidth" = "8";
			};
			package = codepkg;
		};
	};
}
