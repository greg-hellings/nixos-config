{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  toPythonModule,
  pipenv,
}:

buildPythonPackage rec {
  pname = "xonsh-apipenv";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "greg-hellings";
    repo = "xontrib-apipenv";
    rev = version;
    hash = "sha256-Wa8iev0ow1oh95tPCv5tAJUMBYiStWms8I31WbVcOok=";
  };

  dependencies = [ (toPythonModule pipenv) ];

  meta = with lib; {
    description = "Auto pipenv support for Xonsh";
    homepage = "https://github.com/greg-hellings/xontrib-apipenv";
    license = licenses.mit;
    maintainers = [ ];
  };
}
