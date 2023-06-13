{ lib, buildPythonPackage, fetchPypi, pkgs}:

let
    pydeps = pypkgs: with pypkgs; [
        click
        django
        python-dotenv
        pytz
        setuptools
        sqlparse
        zipp
    ];
in buildPythonPackage rec {
    pname = "django-rapyd-modernauth";
    version = "0.0.4";

    src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-kDZjI32LcKsmLI38ruINKOUfi6lWTIqXF5qIQHi0LeQ=";
    };

    meta = with lib; {
        description = "A Django application that provides a custom User model where the username is the email address.";
        homepage = "https://github.com/karthicraghupathi/django_rapyd_modernauth";
        license = licenses.afl20;
        maintainers = [];
    };

    doCheck = false;

    buildInputs = with pkgs; [
        #(python3.withPackages pydeps)
        click
        django
        python-dotenv
        pytz
        setuptools
        sqlparse
        zipp
    ];

    nativeBuildInputs = with pkgs; [
        #(python3.withPackages pydeps)
    ];
}
