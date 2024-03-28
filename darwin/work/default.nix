{ pkgs, ... }:

{
	homebrew = {
		enable = true;
		brews = [
			"packer"
			"direnv"
		];
		casks = [
			"alt-tab"
			"gnucash"
			"insomnia"
			"onlyoffice"
			"pgadmin4"
			"postman"
			"vagrant"
		];
	};
	environment.loginShell = "${pkgs.xonsh}/bin/xonsh";
}
