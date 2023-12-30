{
	lib,
	buildPythonPackage,
	fetchFromGitHub,

	amqplib,
	mock,
	pytestCheckHook,
	requests,
}:

buildPythonPackage rec {
	pname = "graypy";
	version = "2.1.0";

	src = fetchFromGitHub {
		owner = "severb";
		repo = "graypy";
		rev = "2.1.0";
		hash = "sha256-y1HbJEpqnAgOeB+zXKy3iUT6Lpv0bufjL7+jWUSAjFs=";
	};

	nativeCheckInputs = [
		amqplib
		mock
		pytestCheckHook
		requests
	];

	meta = with lib; {
		description = "Python logging handlers that send messages in the Graylog Extended Log Format (GELF).";
		homepage = "https://github.com/severb/graypy";
		license = licenses.bsd3;
	};
}
