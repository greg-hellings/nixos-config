self: super:

let
	cp = super.python3.pkgs.callPackage;

	myPackages = pypackages: with pypackages; with pkgs.my-py-addons; [
		black
		copier
		datadog
		datadog-api-client
		dateutil
		flake8
		ipython
		jedi
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

	myPython = super.python3.withPackages myPackages;
	macOver = file: og:
		if super.stdenv.isDarwin then
		(super.callPackage file {}) else
		super."${og}";

	buildFirefoxXpiAddon = super.lib.makeOverridable ({ stdenv ? super.stdenv
	, fetchurl ? super.fetchurl, pname, version, addonId, url, sha256, meta, ...
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

	my-py-addons = rec {
		copier =  cp ./copier.nix {
			inherit iteration-utilities
			        jinja2-ansible-filters
			        pydantic
			        pyyaml-include
			;
		};
		datadog-api-client = cp ./datadog-api-client.nix {};
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
		pydantic = cp ./pydantic.nix {};
		pyyaml-include = cp ./pyyaml-include.nix {};
		xonsh-direnv = cp ./xonsh-direnv.nix {};
	};

	bypass-paywalls-clean = let version = "3.1.5.0";
	in buildFirefoxXpiAddon {
		pname = "bypass-paywalls-clean";
		inherit version;
		addonId = "{d133e097-46d9-4ecc-9903-fa6a722a6e0e}";
		url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-${version}.xpi";
		sha256 = "sha256-mBJkX8neimU5nwr1GEccCEr6Zy1Ku3JEH2A3LmPF3SU=";
		meta = with super.lib; {
			homepage = "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
			description = "Bypass Paywalls of (custom) news sites";
			license = licenses.mit;
			platforms = platforms.all;
		};
	};

	enwiki-dump = super.callPackage ./enwiki-dump.nix {};
	hms = super.callPackage ./hms.nix {
		pkgs = self.pkgs;
	};
	setup-ssh = super.callPackage ./setup-ssh.nix {
		pkgs = self.pkgs;
	};
	kiwix-tools = super.callPackage ./kiwix-tools.nix {};
	libkiwix = super.callPackage ./libkiwix.nix {};
	zimlib = super.callPackage ./zimlib.nix {};

	xonsh = super.xonsh.overridePythonAttrs (old: rec{
		python3 = self.gregpy;
		propagatedBuildInputs = old.propagatedBuildInputs ++ [ my-py-addons.xonsh-direnv ];
	});

	bitwarden = macOver ./mac/bitwarden.nix "bitwarden";
	gnucash = macOver ./mac/gnucash.nix "gnucash";
	handbrake = macOver ./mac/handbrake.nix "handbrake";
	onlyoffice-bin = macOver ./mac/onlyoffice-bin.nix "onlyoffice-bin";
	vlc = macOver ./mac/vlc.nix "vlc";
}
