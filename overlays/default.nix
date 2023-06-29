final: prev:

let
	myPackages = pypackages: with pypackages; [
		black
		copier
		dateutil
		flake8
		ipython
		jedi
		jedi-language-server
		mypy
		pylint
		pyyaml
		responses
		ruamel-yaml
		tox
		typing-extensions
		virtualenv
		xonsh-direnv
	];

	myPython = prev.python3.withPackages myPackages;
	macOver = file: og:
		if prev.stdenv.isDarwin then
		(prev.callPackage file {}) else
		prev."${og}";

	buildFirefoxXpiAddon = prev.lib.makeOverridable ({ stdenv ? prev.stdenv
	, fetchurl ? prev.fetchurl, pname, version, addonId, url, sha256, meta, ...
	}:
	stdenv.mkDerivation {
		name = "${pname}-${version}";

		inherit meta;

		src = fetchurl { inherit url sha256; };

		preferLocalBuild = true;
		allowSubstitutes = true;

		buildCommand = ''
			dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
			mkdir -p "$dst"
			install -v -m644 "$src" "$dst/${addonId}.xpi"
		'';
	});

in rec {
	gregpy = myPython;

	## Testing adding python packages in the correct manner
	pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
		(python-final: python-prev: let cp = python-final.callPackage; in {
			django-rapyd-modernauth = cp ./django-rapyd-modernauth.nix {};
			xonsh-apipenv = cp ./xonsh-apipenv.nix {};
			xonsh-direnv = cp ./xonsh-direnv.nix {};
			copier =  cp ./copier.nix {
				inherit (python-final)
				    iteration-utilities
				    jinja2-ansible-filters
				    pyyaml-include;
			};
			iteration-utilities = cp ./iteration-utilities.nix {};
			jinja2-ansible-filters = cp ./jinja2-ansible-filters.nix {};
			pyyaml-include = cp ./pyyaml-include.nix {};
		})
	];

	brew = prev.callPackage ./homebrew.nix {};

	enwiki-dump = prev.callPackage ./enwiki-dump.nix {};
	hms = prev.callPackage ./hms.nix {
		pkgs = final.pkgs;
	};
	inject = prev.callPackage ./inject.nix { inherit (final) pkgs; };
	setup-ssh = prev.callPackage ./setup-ssh.nix {
		pkgs = final.pkgs;
	};

	xonsh = prev.xonsh.overridePythonAttrs (old: rec{
		python3 = final.gregpy;
		propagatedBuildInputs = with final.gregpy.pkgs; old.propagatedBuildInputs ++ [
			xonsh-apipenv
			xonsh-direnv
		];
	});

	bitwarden = macOver ./mac/bitwarden.nix "bitwarden";
	gnucash = macOver ./mac/gnucash.nix "gnucash";
	handbrake = macOver ./mac/handbrake.nix "handbrake";
	onlyoffice-bin = macOver ./mac/onlyoffice-bin.nix "onlyoffice-bin";
	vlc = macOver ./mac/vlc.nix "vlc";
}
