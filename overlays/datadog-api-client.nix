{ lib, buildPythonPackage, fetchPypi, pkgs}:

buildPythonPackage rec {
	pname = "datadog-api-client";
	version = "2.3.0";

	src = fetchPypi {
		inherit pname version;
		sha256 = "";
	};

	meta = with lib; {
		description = "Datadog API client support";
		homepage = "https://github.com/DataDog/datadog-api-client-python";
		license = licenses.bsd;
		maintainers = [];
	};

	doCheck = false;
}
