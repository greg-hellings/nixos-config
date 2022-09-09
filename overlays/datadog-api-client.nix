{ lib, buildPythonPackage, fetchPypi, pkgs}:

buildPythonPackage rec {
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
}
