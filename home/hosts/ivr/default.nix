{ pkgs, lib, inputs, ...}:
let
	py = pkgs.nix23_05.python311.withPackages ( p: with p; [
		django
		djangorestframework
		django-rapyd-modernauth
		environs
		mysqlclient
		pyyaml
		ruamel-yaml
		tox
	]);
in {
	greg = {
		development = true;
		pypackage = py;
		vscodium = true;
	};
	home = {
		packages = with pkgs; [
			aacs
			ansible
			bitwarden-cli
			direnv
			home-manager
			insomnia
			pipenv-ivr
			poetry
		];
		file.".pip/pip.conf".text = (lib.strings.concatStringsSep "\n" [
			"[global]"
			"retries = 1"
			"index-url = https://pypi.python.org/simple"
			"extra-index-url ="
			"    https://pypi.ivrtechnology.com/simple/"
			"    https://pypidev.ivrtechnology.com/simple/"
		]);
		username = "gregory.hellings";
		homeDirectory = lib.mkForce "/home/gregory.hellings";
	};
}
