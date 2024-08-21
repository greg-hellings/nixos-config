{
	lib,
	buildPythonPackage,
	fetchFromGitHub,
	pipenv,
}:

buildPythonPackage rec {
	pname = "xonsh-apipenv";
	version = "0.5.0";

	src = fetchFromGitHub {
		owner = "greg-hellings";
		repo = "xontrib-apipenv";
		rev = "0.5.0";
		hash = "sha256-QJatIiIP1YVT8M5vLUPHmf/8CGZ34cXMBXQmfSgY5C4=";
	};

	doCheck = false;

	dependencies = [
		pipenv
	];

	meta = with lib; {
		description = "Auto pipenv support for Xonsh";
		homepage = "https://github.com/greg-hellings/xontrib-apipenv";
		license = licenses.mit;
		maintainers = [];
	};
}
