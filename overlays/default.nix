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

	## Testing adding python packages in the correct manner
	pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
		(python-final: python-prev: let cp = python-final.callPackage; in {
			django-rapyd-modernauth = cp ./django-rapyd-modernauth.nix {};
			xonsh-apipenv = cp ./xonsh-apipenv.nix {};
			xonsh-direnv = cp ./xonsh-direnv.nix {};
			xontrib-vox = cp ./xonsh-vox.nix {};
			copier =  cp ./copier.nix {
				inherit (python-final)
				    iteration-utilities
				    jinja2-ansible-filters
				    pyyaml-include;
			};
		})
	];

	aacs = prev.callPackage ./aacs.nix {};
	brew = prev.callPackage ./homebrew.nix {};
	enwiki-dump = prev.callPackage ./enwiki-dump.nix {};
	hms = prev.callPackage ./hms.nix {
		pkgs = final.pkgs;
	};
	inject = prev.callPackage ./inject.nix { inherit (final) pkgs; };
	libbluray-custom = prev.libbluray.override {
		withAACS = true;
		withBDplus = true;
	};
	setup-ssh = prev.callPackage ./setup-ssh.nix {
		pkgs = final.pkgs;
	};
	template = prev.callPackage ./template.nix { };
	handbrake = prev.handbrake.override {
		libbluray = libbluray-custom;
	};

	xonsh = prev.xonsh.overridePythonAttrs (old: rec{
		python3 = final.gregpy;
		propagatedBuildInputs = with final.gregpy.pkgs; old.propagatedBuildInputs ++ [
			responses
			ruamel-yaml
			xonsh-apipenv
			xonsh-direnv
			xontrib-vox
		];
	});
}
