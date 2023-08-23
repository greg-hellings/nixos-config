{ pkgs, ... }:

{
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
}
