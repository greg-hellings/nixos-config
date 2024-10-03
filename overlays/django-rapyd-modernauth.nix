{ lib
, buildPythonPackage
, fetchPypi
, click
, django
, python-dotenv
, pytz
, setuptools
, sqlparse
, zipp
}:

buildPythonPackage rec {
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
    maintainers = [ ];
  };

  doCheck = false;

  buildInputs = [
    click
    django
    python-dotenv
    pytz
    setuptools
    sqlparse
    zipp
  ];

  nativeBuildInputs = [
  ];
}
