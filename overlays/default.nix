final: prev:

let
	cp = prev.python3.pkgs.callPackage;

	myPackages = pypackages: with pypackages; with pkgs.my-py-addons; [
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
		(python-final: python-prev: {
			django-rapyd-modernauth = python-final.callPackage ./django-rapyd-modernauth.nix {};
			xonsh-apipenv = cp ./xonsh-apipenv.nix {};
			xonsh-direnv = cp ./xonsh-direnv.nix {};
		})
	];

	my-py-addons = rec {
		copier =  cp ./copier.nix {
			inherit iteration-utilities
			        jinja2-ansible-filters
			        pyyaml-include
			;
		};
		iteration-utilities = cp ./iteration-utilities.nix {};
		jinja2-ansible-filters = cp ./jinja2-ansible-filters.nix {};
		molecule = cp ./molecule.nix {};
		molecule-containers = cp ./molecule-containers.nix {
			inherit molecule molecule-docker molecule-podman;
		};
		molecule-docker = cp ./molecule-docker.nix {
			inherit molecule;
		};
		molecule-podman = cp ./molecule-podman.nix {
			inherit molecule;
		};
		pyyaml-include = cp ./pyyaml-include.nix {};
	};

	#fcitx-engines = if ! prev.stdenv.isDarwin then prev.fcitx5 else prev.fcitx-engines;
	brew = prev.callPackage ./homebrew.nix {};

	enwiki-dump = prev.callPackage ./enwiki-dump.nix {};
	hms = prev.callPackage ./hms.nix {
		pkgs = final.pkgs;
	};
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
