{ lib, stdenv, fetchFromGitHub
, meson, ninja, pkg-config
, python3
, icu
, libuuid
, xapian
, xz
, zstd
, gtest
}:

stdenv.mkDerivation rec {
  pname = "zimlib";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "openzim";
    repo = "libzim";
    rev = version;
    sha256 = "sha256-ab7UUF+I0/xaGChvdjylEQRHLOjmtg/wk+/JEGehGLE=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    python3
  ];

  propagatedBuildInputs = [
    icu
    libuuid
    xapian
    xz
    zstd
  ];

  postPatch = ''
    patchShebangs scripts
  '';

  mesonFlags = [ "-Dtest_data_dir=none" ];

  checkInputs = [
    gtest
  ];

  doCheck = true;

  meta = with lib; {
    description = "Library for reading and writing ZIM files";
    homepage =  "https://www.openzim.org/wiki/Zimlib";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ajs124 ];
    platforms = platforms.linux;
  };
}
