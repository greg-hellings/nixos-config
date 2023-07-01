{ lib, buildPythonPackage, fetchFromGitHub, pkgs}:

buildPythonPackage rec {
	pname = "xontrib-vox";
	version = "0.0.1";

	src = fetchFromGitHub {
		owner = "xonsh";
		repo = "xontrib-vox";
		rev = "0.0.1";
		hash = "sha256-OB1O5GZYkg7Ucaqak3MncnQWXhMD4BM4wXsYCDD0mhk=";
	};

	prePatch = ''
		substituteInPlace pyproject.toml --replace '"xonsh>=0.12.5"' ""
	'';

	meta = with lib; {
		description = "Direnv support for Xonsh";
		homepage = "https://github.com/74th/xonsh-direnv/";
		license = licenses.mit;
		maintainers = [];
	};

	patchPhase = "sed -i -e 's/^dependencies.*$/dependencies = []/' pyproject.toml";

	doCheck = false;

	nativeBuildInputs = [
		pkgs.git
	];
}
