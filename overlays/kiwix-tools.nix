{ lib, pkgs, stdenv
 , cmake
 , meson
 , ninja
 , pkg-config

 , curl
 , libkiwix
 , libmicrohttpd
 , pugixml
 , zimlib
 , ...}:

stdenv.mkDerivation rec {
	pname = "kiwix-tools";
	version = "3.4.0";

	src = pkgs.fetchFromGitHub {
		owner = "kiwix";
		repo = pname;
		rev = version;
		sha256 = "sha256-r3/aTH/YoDuYpKLPakP4toS3OtiRueTUjmR34rdmr+w=";
	};

	nativeBuildInputs = [
		meson
		ninja
		pkg-config
	];

	buildInputs = [
		curl
		libkiwix
		libmicrohttpd
		pugixml
		zimlib
	];

	meta = with lib; {
		description = "An offline read for Web content tools (HTTP server, search, etc)";
		homepage = "https://kiwix.org";
		license = licenses.gpl3Plus;
		platforms = platforms.all;
		maintainers = [ "Greg Hellings <greg.hellings@gmail.com>" ];
	};
}
