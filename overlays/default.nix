final: prev:

let
	myPackages = pypackages: with pypackages; [
		black
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
	];

	myPython = prev.python3.withPackages myPackages;
	macOver = file: og:
		if prev.stdenv.isDarwin then
		(prev.callPackage file {}) else
		prev."${og}";

	buildFirefoxXpiAddon = final.nur.repos.rycee.lib.buildFirefoxXpiAddon;

in rec {
	gregpy = myPython;
	bypass-paywalls = final.nur.repos.rycee.firefox-addons.bypass-paywalls-clean.override {
		version = "3.2.6.0";
		url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-3.2.6.0-custom.xpi";
		sha256 = "sha256-dEdqg0q4w+evky7oZ4l33GPEBEc/PFG2dCsQkVY9/3g=";
	};

	## Testing adding python packages in the correct manner
	pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
		(python-final: python-prev: let cp = python-final.callPackage; in {
			django-rapyd-modernauth = cp ./django-rapyd-modernauth.nix {};
			xonsh-apipenv = cp ./xonsh-apipenv.nix {};
			xonsh-direnv = cp ./xonsh-direnv.nix {};
			xontrib-vox = cp ./xonsh-vox.nix {};
		})
	];

	brew = prev.callPackage ./homebrew.nix {};
	setup-ssh = prev.callPackage ./setup-ssh.nix {
		pkgs = final.pkgs;
	};
	hms = prev.callPackage ./hms.nix {
		pkgs = final.pkgs;
	};
	jinja2-cli = prev.python3.pkgs.callPackage ./jinja2-cli.nix {};
	template = prev.callPackage ./template.nix { };

	enwiki-dump = prev.callPackage ./enwiki-dump.nix {};
	inject = prev.callPackage ./inject.nix { inherit (final) pkgs; };

	xonsh = prev.xonsh.overridePythonAttrs (old: rec{
		python3 = final.gregpy;
		propagatedBuildInputs = with final.gregpy.pkgs; old.propagatedBuildInputs ++ [
			xonsh-apipenv
			xonsh-direnv
			xontrib-vox
		];
	});

	bitwarden = macOver ./mac/bitwarden.nix "bitwarden";
	gnucash = macOver ./mac/gnucash.nix "gnucash";
	handbrake = macOver ./mac/handbrake.nix "handbrake";
	onlyoffice-bin = macOver ./mac/onlyoffice-bin.nix "onlyoffice-bin";
	vlc = macOver ./mac/vlc.nix "vlc";
}
