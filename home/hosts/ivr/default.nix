{ pkgs, lib, inputs, ...}:
let
	py = pkgs.nix23_05.python311.withPackages ( p: with p; [
		django
		djangorestframework
		django-rapyd-modernauth
		environs
		#itg-django-utils
		mysqlclient
		pyyaml
		ruamel-yaml
		tox
	]);
in {
	imports = [
		../../vscodium.nix
	];

	greg.pypackage = py;
	home = {
		packages = with pkgs; [
			aacs
			ansible
			bitwarden-cli
			bruno
			direnv
			gcc
			home-manager
			insomnia
			libmysqlclient
			pipenv-ivr
			pkg-config
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
