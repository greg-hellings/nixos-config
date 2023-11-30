{ pkgs, ... }:

{
	homebrew = {
		enable = true;
		brews = [
			"packer"
		];
		casks = [
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
