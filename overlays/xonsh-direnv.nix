{ lib, buildPythonPackage, fetchPypi, pkgs}:

buildPythonPackage rec {
	pname = "xonsh-direnv";
	version = "1.6.1";

	src = fetchPypi {
		inherit pname version;
		sha256 = "Nt8Da1EtMVWZ9mbBDjys7HDutLYifwoQ1HVmI5CN2Ww=";
	};

	meta = with lib; {
		description = "Direnv support for Xonsh";
		homepage = "https://github.com/74th/xonsh-direnv/";
		license = licenses.mit;
		maintainers = [];
	};

	doCheck = false;

	nativeBuildInputs = [
		pkgs.git
	];
}
