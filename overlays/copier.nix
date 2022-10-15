{ lib, buildPythonPackage, fetchPypi, pkgs,
colorama,
dunamai,
iteration-utilities,
jinja2,
jinja2-ansible-filters,
packaging,
pathspec,
plumbum,
pydantic,
pygments,
pyyaml,
pyyaml-include,
questionary,
setuptools,
wheel}:

let
	pydeps = [
		colorama
		dunamai
		iteration-utilities
		jinja2
		jinja2-ansible-filters
		packaging
		pathspec
		plumbum
		pydantic
		pygments
		pyyaml
		pyyaml-include
		questionary
		setuptools
		wheel
	];
in buildPythonPackage rec {
	pname = "copier";
	version = "6.2.0";

	src = fetchPypi {
		inherit pname version;
		sha256 = "sha256-eSxm7Rpu3dhWkLoSA1/b8IemWxjIsHwlJ+NYEpbilkk=";
	};

	meta = with lib; {
		description = "A library and CLI app for rendering templates";
		homepage = "https://github.com/copier-org/copier";
		license = licenses.mit;
		maintainers = [];
	};

	doCheck = false;

	propagatedBuildInputs = pydeps;

	buildInputs = [];
}
