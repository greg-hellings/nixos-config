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
			"vmware-fusion"
		];
	};
}
