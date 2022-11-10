{ stdenv, fetchurl,
  undmg,
}:

stdenv.mkDerivation rec {
	version = "3.0.17.3";
	pname = "vlc";

	buildInputs = [
		undmg
	];
	sourceRoot = ".";
	phases = [
		"unpackPhase"
		"installPhase"
	];
	installPhase = ''
		mkdir -p "$out/Applications"
		cp -r *.app "$out/Applications"
	'';

	src = fetchurl {
		name = "${pname}-${version}.dmg";
		url = "https://get.videolan.org/vlc/${version}/macosx/${pname}-${version}-intel64.dmg";
		sha256 = "sha256-zKJn8sUa5WjgLztNimrbqHsr3l8BGiuHxZXBAtifEdg=";
	};

	meta = {
		description = "VLC is a very versatile video player.";
		homepage = "https://www.videolan.org/";
	};
}
