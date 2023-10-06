{ pkgs, ... }:

{
	homebrew = {
		enable = true;
		brews = [
			"packer"
		];
		casks = [
			"gnucash"
			"onlyoffice"
			"pgadmin4"
			"postman"
			"vagrant"
		];
	};
	environment.loginShell = "${pkgs.xonsh}/bin/xonsh";
}
