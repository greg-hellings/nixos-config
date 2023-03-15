{ lib, pkgs, stdenv
 , curl
 , icu
 , pugixml
 , mustache-hpp
 , libmicrohttpd
 , zimlib
 , zlib

 , bash
 , gcc
 , gtest
 , meson
 , ninja
 , pkg-config
 , python3
 , ...}:

stdenv.mkDerivation rec {
	pname = "libkiwix";
	version = "12.0.0";

	src = pkgs.fetchFromGitHub {
		owner = "kiwix";
		repo = pname;
		rev = version;
		sha256 = "sha256-4FxLxJxVhqbeNqX4vorHkROUuRURvE6AXlteIZCEBtc=";
	};

	nativeBuildInputs = [
		bash
		gcc
		gtest
		meson
		ninja
		pkg-config
		python3
	];

	buildInputs = [
		curl
		icu
		libmicrohttpd
		mustache-hpp
		pugixml
		zimlib
		zlib
	];

	mesonFlags = [ "--debug" "-Dc_args=-I${zimlib}/include/" ];

	# Built-in python script uses /usr/bin/env
	patchPhase = "patchShebangs --build scripts/*";

	meta = with lib; {
		description = "Kiwix file library for use by other applications";
		homepage = "https://kiwix.org";
		license = licenses.gpl3Plus;
		platforms = platforms.all;
		maintainers = [ "Greg Hellings <greg.hellings@gmail.com>" ];
	};
}
