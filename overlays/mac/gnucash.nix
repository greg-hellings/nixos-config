{ stdenv, fetchurl,
  undmg,
}:

stdenv.mkDerivation rec {
	version = "4.12";
	pname = "GnuCash";

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
		cp -r Gnucash*.app "$out/Applications"
	'';

	src = fetchurl {
		name = "${pname}-${version}.dmg";
		url = "https://sourceforge.net/projects/gnucash/files/gnucash%20(stable)/${version}/Gnucash-Intel-${version}-1.dmg";
		sha256 = "sha256-GXsGOk+F/QdcD19ZmZmor0upCFHa7iy3Hs4CLbiby1M=";
	};

	meta = {
		description = "GnuCash is free accounting software for your local machine";
		homepage = "https://www.gnucash.org";
	};
}
