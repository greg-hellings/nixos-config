{ lib
, buildPythonPackage
, fetchurl
, django
, djangorestframework
, graypy
, setuptools
,
}:

buildPythonPackage rec {
  pname = "itg-django-utils";
  version = "0.1.11";

  src = fetchurl {
    url = "https://pypi.ivrtechnology.com/packages/itg-django-utils-0.1.12.tar.gz";
    hash = "sha256-LbOl4L4UZbRTlLuBL4L3ser6+WDuP3R5a03EIh1xSK8=";
  };

  propagatedBuildInputs = [
    django
    djangorestframework
    graypy
    setuptools
  ];

  meta = with lib; {
    description = "ITG specific stuff";
    homepage = "http://www.ivrtechnology.com";
    maintainers = [ ];
  };

  doCheck = false;
}
