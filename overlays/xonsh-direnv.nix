{ lib, buildPythonPackage, fetchPypi, pkgs}:

buildPythonPackage rec {
	pname = "xonsh-direnv";
	version = "1.5.0";

	src = fetchPypi {
		inherit pname version;
		sha256 = "OLjtGD2lX4Yf3aHrxCWmAbSPZnf8OuVrBu0VFbsna1Y=";
	};

	meta = with lib; {
		description = "Direnv support for Xonsh";
		homepage = "https://github.com/74th/xonsh-direnv/";
		license = licenses.mit;
		maintainers = [];
	};

	doCheck = false;
}
