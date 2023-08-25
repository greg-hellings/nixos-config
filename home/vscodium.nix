{ pkgs, ... }:

{
	home.packages = with pkgs; [
		buildifier
		gopls
	];

	# An alternative editor to vim, when I need it for some things
	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		extensions = with pkgs.vscode-extensions; [
			golang.go
			ms-python.python
			vscjava.vscode-java-test
			vscjava.vscode-java-dependency
			vscjava.vscode-java-debug
			vscodevim.vim
		];
	};
}
