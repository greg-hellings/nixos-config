{ lib, buildPythonPackage, fetchPypi, pkgs}:

buildPythonPackage rec {
	pname = "iteration-utilities";
	version = "0.11.0";

	src = fetchPypi {
		inherit version;
		pname = "iteration_utilities";
		sha256 = "sha256-+R9BolSemn5A/1Rg/fkDO27lswXZvneUO2OlVFNMKnc=";
	};

	meta = with lib; {
		description = "Utilities based on Pythons iterators and generators.";
		homepage = "https://github.com/MSeifert04/iteration_utilities";
		license = licenses.afl20;
		maintainers = [];
	};

	propagatedBuildInputs = [];

	doCheck = false;
}
