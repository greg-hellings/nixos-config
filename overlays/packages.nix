{ pkgs, ... }:

let
	callPackage = pkgs.lib.callPackageWith pkgs;
	lib = pkgs.lib;
	python = pkgs.packages.python3;
in {
	datadog-api-client = callPackage ./datadog-api-client.nix {
		inherit pkgs lib;
		buildPythonPackage = python.pkgs.buildPythonPackage;
		fetchPypi = pkgs.python.pkgs.fetchPypi;
	};

	hms = pkgs.callPackage ./hms.nix {
		inherit pkgs;
	};

	xonsh-direnv = pkgs.callPackage ./xonsh-direnv.nix {
		buildPythonPackage = pkgs.python3.pkgs.buildPythonPackage;
		fetchPypi = pkgs.python.pkgs.fetchPypi;
	};

}
