{ lib, buildPythonPackage, fetchPypi, pkgs,
setuptools, setuptools-scm, setuptools-scm-git-archive, wheel,
docker,
molecule,
selinux-python,
}:

let
	pydeps = [
		docker
		molecule
		selinux-python
	];
in buildPythonPackage rec {
	pname = "molecule-docker";
	version = "2.1.0";

	src = fetchPypi {
		inherit pname version;
		sha256 = "sha256-GVuXZzy8IzXPpoEIFt5cv4B1B781Cp0WypiyJLFkcUU=";
	};

	meta = with lib; {
		description = "A plugin for Molecule providing Docker resources";
		homepage = "https://github.com/ansible-community/molecule-docker";
		license = licenses.mit;
		maintainers = [];
	};

	doCheck = false;

	# Gets pulled into running environments as well
	propagatedBuildInputs = pydeps;

	format = "pyproject";  # For when it has only pyproject.toml
	# Only needed at the buid stage
	buildInputs = [
		setuptools
		setuptools-scm
		setuptools-scm-git-archive
		wheel
	];

	nativeBuildInputs = with pkgs; [
	];
}
