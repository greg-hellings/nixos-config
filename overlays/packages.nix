{ pkgs, ... }:

{
	datadog-api-client = pkgs.callPackage ./datadog-api-client.nix {
		buildPythonPackage = pkgs.python3.pkgs.buildPythonPackage;
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
