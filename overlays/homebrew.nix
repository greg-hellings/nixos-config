{
lib,
pkgs,
stdenv,

bash,
curl,
git,
ruby,
...}:

stdenv.mkDerivation rec {
	pname = "homebrew-installer";
	version = "20230531";

	src = pkgs.fetchFromGitHub {
		owner = "Homebrew";
		repo = "install";
		rev = "716a1d024f32890ef75ea82c18a769abc24e9475";
		sha256 = "sha256-xhxWWeCJm49bDzmBT2GHSC0CK1SoQArBhfh5sltGY5o=";
	};

	buildInputs = [
		bash
		curl
		git
		ruby
	];

	installPhase = ''
		mkdir -p $out/bin/
		cp ${src}/install.sh $out/bin/install-homebrew.sh
		cp ${src}/uninstall.sh $out/bin/uninstall-homebrew.sh
	'';

	meta = with lib; {
		description = "Runs the homebrew installer";
		homepage = "https://github.com/Homebrew/";
		license = licenses.bsd2;
		platforms = [ "aarch64-darwin" "x86_64-darwin" ];
		maintainers = [ maintainers.greg ];
	};
}
