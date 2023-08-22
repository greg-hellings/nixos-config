{
	lib,
	buildPythonPackage,
	fetchFromGitHub,

	flake8,
	jinja2,
	pytestCheckHook,
	setuptools,
}:

buildPythonPackage {
    pname = "jinja2-cli";
    version = "0.8.2";

    src = fetchFromGitHub {
        owner = "mattrobenolt";
        repo = "jinja2-cli";
        rev = "0.8.2";
        hash = "sha256-67gYt0nZX+VTVaoSxVXGzbRiXD7EMsVBFWC8wHo+Vw0=";
    };

    propagatedBuildInputs = [
        jinja2
        setuptools
    ];

    checkInputs = [
        flake8
        pytestCheckHook
    ];

    meta = with lib; {
        description = "A CLI interface for Jinja2 templates";
        homepage = "https://github.com/mattrobenolt/jinja2-cli";
        license = licenses.bsd2;
        maintainers = [ lib.maintainers.greg ];
    };
}
