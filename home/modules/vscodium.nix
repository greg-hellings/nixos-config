{ pkgs, config, lib, ... }:

let
	cfg = config.greg.vscodium;
in {
	options.greg.vscodium = lib.mkEnableOption "Enable installation of VSCodium on the host";

	config = lib.mkIf cfg {
		home.packages = with pkgs; [
			buildifier
			gopls
		];

		# An alternative editor to vim, when I need it for some things
		programs.vscode = {
			enable = true;
			package = pkgs.vscodium;
			extensions = with pkgs.vscode-extensions; [
				arrterian.nix-env-selector
				asvetliakov.vscode-neovim
				bungcip.better-toml
				golang.go
				jnoortheen.nix-ide
				mkhl.direnv
				ms-python.python
				vscjava.vscode-java-test
				vscjava.vscode-java-dependency
				vscjava.vscode-java-debug
			];
		};
	};
}
