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
	version = "9.4.1";

	src = pkgs.fetchFromGitHub {
		owner = "kiwix";
		repo = pname;
		rev = version;
		sha256 = "sha256-vE8bJrNx0oojTgcDhlr+SyfzdpigCZ0pQ2cPYaiZlgw=";
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

	mesonFlags = [ "--debug" ];

	# Built-in python script uses /usr/bin/env
	patchPhase = "patchShebangs --build scripts/kiwix-compile-resources";

	meta = with lib; {
		description = "Kiwix file library for use by other applications";
		homepage = "https://kiwix.org";
		license = licenses.gpl3Plus;
		platforms = platforms.all;
		maintainers = [ "Greg Hellings <greg.hellings@gmail.com>" ];
	};
}
