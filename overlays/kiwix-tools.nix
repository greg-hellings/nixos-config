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
	version = "3.1.2";

	src = pkgs.fetchFromGitHub {
		owner = "kiwix";
		repo = pname;
		rev = version;
		# For 3.3.0
		#sha256 = "sha256-jeIyHTbgGrYknLaTNNSFVFo9zXyyGZU6dIVv49bEhBw=";
		sha256 = "sha256-i3wr0VZCeH3aRCgphIyn6U91Ja+qVT4NVAzJSmniu8o=";
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
