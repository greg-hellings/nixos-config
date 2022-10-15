{ lib, buildPythonPackage, fetchPypi, pkgs,
pyyaml,
setuptools,
setuptools-scm,
setuptools-scm-git-archive,
wheel
}:

let
	pydeps = [
		pyyaml
	];
in buildPythonPackage rec {
	pname = "pyyaml-include";
	version = "1.3";

	src = fetchPypi {
		inherit pname version;
		sha256 = "sha256-9/vrjnG1C+Dm4HRy98edv7GhW63pyToHg2n/SeV+Z3E=";
	};

	meta = with lib; {
		description = "A PyYAML extension to allow includes.";
		homepage = "https://github.com/tanbro/pyyaml-include";
		license = licenses.gpl3;
		maintainers = [];
	};

	doCheck = false;

	propagatedBuildInputs = pydeps;

	buildInputs = [
		setuptools
		setuptools-scm
		setuptools-scm-git-archive
		wheel
	];

	nativeBuildInputs = with pkgs; [
	];
}
