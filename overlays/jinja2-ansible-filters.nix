{ lib, buildPythonPackage, fetchPypi, pkgs}:

let
        pydeps = pypkgs: with pypkgs; [
                ansible-core
                setuptools
                wheel
        ];
in buildPythonPackage rec {
        pname = "jinja2-ansible-filters";
        version = "1.3.2";

        src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-B8EM9E1wc/TwEQLKEtmi3DG0HUfkxh7ZLvam0mabNWs=";
        };

        meta = with lib; {
                description = "A port of the Jinja2 filters from Ansible";
                homepage = "https://gitlab.com/dreamer-labs/libraries/jinja2-ansible-filters";
                license = licenses.gpl3;
                maintainers = [];
        };

        doCheck = false;

        buildInputs = with pkgs; [
                (python3.withPackages pydeps)
        ];

        nativeBuildInputs = with pkgs; [
                (python3.withPackages pydeps)
        ];
}
