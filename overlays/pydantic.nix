{ lib, buildPythonPackage, fetchPypi, pkgs,
typing-extensions
}:

let
	pydeps = [
		typing-extensions
	];
in buildPythonPackage rec {
	pname = "pydantic";
	version = "1.10.2";

	src = fetchPypi {
		inherit pname version;
		sha256 = "sha256-kbjiGIUu9gB8K5jNhhYBxqCfGqMru7dPq1scM9Sh5BA=";
	};

	meta = with lib; {
		description = "Data validation and settings management using Python type hints.";
		homepage = "https://github.com/pydantic/pydantic";
		license = licenses.mit;
		maintainers = [];
	};

	doCheck = false;

	propagatedBuildInputs = pydeps;

	buildInputs = [];

	nativeBuildInputs = with pkgs; [
	];
}
