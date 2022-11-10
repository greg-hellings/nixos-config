{ stdenv, fetchurl,
  undmg,
}:

stdenv.mkDerivation rec {
	version = "1.5.1";
	pname = "HandBrake";

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
		cp -r ${pname}*.app "$out/Applications"
	'';

	src = fetchurl {
		name = "${pname}-${version}.dmg";
		url = "https://github.com/HandBrake/HandBrake/releases/download/${version}/${pname}-${version}.dmg";
		sha256 = "sha256-dnyxYxTjhpxCz/eNuSvK16f6qGHHD5exMm/jaGxith8=";
	};

	meta = {
		description = "HandBrake is an open source video transcoder";
		homepage = "https://handbrake.fr/";
	};
}
