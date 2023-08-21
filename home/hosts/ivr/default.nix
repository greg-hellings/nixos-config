{ pkgs, lib, ...}:

{
	home.packages = with pkgs; [
		brew
	];
	home.file.".pip/pip.conf".text = (lib.strings.concatStringsSep "\n" [
		"[global]"
		"retries = 1"
		"index-url = https://pypi.python.org/simple"
		"extra-index-url ="
		"    https://pypi.ivrtechnology.com/simple/"
		"    https://pypidev.ivrtechnology.com/simple/"
	]);
}
