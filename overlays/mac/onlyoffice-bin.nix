{ stdenv, fetchurl,
  undmg,
}:

stdenv.mkDerivation rec {
	version = "7.2.1";
	pname = "onlyoffice";

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
		url = "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v${version}/ONLYOFFICE-x86_64.dmg";
		sha256 = "sha256-dsuTaZ+IqsDE/j78ht0Md5NoqQ090cJ4u5LClu3tSp0=";
	};

	meta = {
		description = "OnlyOffice provides a suite of Office-like document editors for the desktop and web.";
		homepage = "https://www.onlyoffice.com/";
	};
}
