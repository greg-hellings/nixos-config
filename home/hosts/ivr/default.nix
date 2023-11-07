{ pkgs, lib, inputs, ...}:

{
	imports = [
		../../vscodium.nix
	];

	home = {
		packages = with pkgs; [
			aacs
			bitwarden-cli
			bruno
			direnv
			home-manager
			pipenv
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
		homeDirectory = "/home/gregory.hellings";
	};
}
