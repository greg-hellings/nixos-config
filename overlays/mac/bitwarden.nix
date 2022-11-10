{ stdenv, fetchurl,
  undmg,
}:

stdenv.mkDerivation rec {
	version = "2022.10.1";
	pname = "Bitwarden";

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
		cp -r Bitwarden*.app "$out/Applications"
	'';

	src = fetchurl {
		name = "Bitwarden-${version}.dmg";
		url = "https://github.com/bitwarden/clients/releases/download/desktop-v${version}/Bitwarden-${version}-universal.dmg";
		sha256 = "sha256-6O8xaGBaG4d6l9QRtGM5wj9OCMFy87dH8N1MfEBBjck=";
	};

	meta = {
		description = "Bitwarden, an open source password management tool";
		homepage = "https://bitwarden.com";
	};
}
