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
			"postman"
			"vagrant"
		];
	};
	environment.loginShell = "${pkgs.xonsh}/bin/xonsh";
}
