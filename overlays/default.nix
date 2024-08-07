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

	myPython = prev.python312.withPackages myPackages;
	macOver = file: og:
		if prev.stdenv.isDarwin then
		(prev.callPackage file {}) else
		prev."${og}";

	buildFirefoxXpiAddon = final.nur.repos.rycee.lib.buildFirefoxXpiAddon;

	is2405 = prev.lib.versionAtLeast prev.lib.version "24";

in rec {
	gregpy = myPython;

	## Testing adding python packages in the correct manner
	pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
		(python-final: python-prev: let cp = python-final.callPackage; in {
			django-rapyd-modernauth = cp ./django-rapyd-modernauth.nix {};
			graypy = cp ./graypy.nix {};
			itg-django-utils = cp ./itg-django-utils.nix {};
			xonsh-apipenv = cp ./xonsh-apipenv.nix {};
			xonsh-direnv = cp ./xonsh-direnv.nix {};
			xontrib-vox = cp ./xonsh-vox.nix {};
		})
	];

	# My own packages
	aacs = prev.callPackage ./aacs.nix {};
	create_ssl = prev.callPackage ./create_ssl.nix {};
	enwiki-dump = prev.callPackage ./enwiki-dump.nix {};
	hms = prev.callPackage ./hms {
		pkgs = final.pkgs;
	};
	inject = prev.callPackage ./inject.nix { inherit (final) pkgs; };
	inject-darwin = prev.callPackage ./inject-darwin.nix { inherit (final) pkgs; };
	setup-ssh = prev.callPackage ./setup-ssh {
		pkgs = final.pkgs;
	};
	upgrade-pg-cluster = prev.callPackage ./upgrade-pg-cluster.nix {};

	# Overrides of packages
	brew = prev.callPackage ./homebrew.nix {};
	copier = (if is2405 then prev.copier.overridePythonAttrs (old: {
		version = "9.1.0";
		src = final.fetchFromGitHub {
			owner = "copier-org";
			repo = "copier";
			rev = "v9.1.0";
			hash = "sha256-x5r7Xv4lAOMkR+UIEeSY7LvbYMLpTWYuICYe9ygz1tA=";
			postFetch = "rm $out/tests/demo/doc/ma*ana.txt";
		};
	}) else prev.copier);
	libbluray-custom = prev.libbluray.override {
		withAACS = true;
		withBDplus = true;
	};
	template = prev.callPackage ./template.nix { };
	handbrake = prev.handbrake.override {
		libbluray = libbluray-custom;
	};
	libvirt-greg = prev.libvirt.overrideAttrs {
		postInstall = prev.libvirt.postInstall + "rm -r $out/lib/systemd/system/libvirtd.service";
	};
	pipenv-ivr = prev.callPackage ./pipenv.nix { };

	myxonsh = (prev.unstable.xonsh-unwrapped.passthru.wrapper.override {
		extraPackages = (ps: with ps; [
			xonsh-apipenv
			xonsh-direnv
			xontrib-vox
		]);
	});
}
