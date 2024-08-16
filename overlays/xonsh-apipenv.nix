{
	lib,
	buildPythonPackage,
	fetchFromGitHub,
	pipenv,
}:

buildPythonPackage rec {
	pname = "xonsh-apipenv";
	version = "0.4.0";

	src = fetchFromGitHub {
		owner = "deeuu";
		repo = "xontrib-apipenv";
		rev = "0.4.0";
		sha256 = "sha256-uFn3kF7P4wykd72XkQx6cPWLhBOh2SDQBcI3Idc2rFM=";
	};

	meta = with lib; {
		description = "Auto pipenv support for Xonsh";
		homepage = "https://github.com/deeuu/xontrib-apipenv";
		license = licenses.mit;
		maintainers = [];
	};

	doCheck = false;

	dependencies = [
		pipenv
	];

	nativeBuildInputs = [
	];
}
