{ lib, buildPythonPackage, fetchPypi, pkgs}:

let
	pydeps = pypkgs: with pypkgs; [
		certifi
		dateutils
		python-dateutil
		setuptools
		setuptools_scm
		typing-extensions
		urllib3
	];

in buildPythonPackage rec {
	pname = "datadog-api-client";
	version = "2.3.0";

	src = fetchPypi {
		inherit pname version;
		sha256 = "CIEQlw8S2lZk1n+ld/Ne7lBx4SKaJZUZfNbw9KvUcjk=";
	};

	meta = with lib; {
		description = "Datadog API client support";
		homepage = "https://github.com/DataDog/datadog-api-client-python";
		license = licenses.asl20;
		maintainers = [];
	};

	doCheck = false;

	buildInputs = with pkgs; [
		(python3.withPackages pydeps)
	];

	nativeBuildInputs = with pkgs; [
		(python3.withPackages pydeps)
		git
	];
}
