{ nixunstable, flake-utils }:

flake-utils.lib.eachDefaultSystemMap (system:
	let
		pkgs = (import nixunstable { inherit system; });
		lib = pkgs.lib;
		callPackage = pkgs.lib.callPackageWith pkgs;
		python = pkgs.packages.python3;
		cp = pkgs.packages.python3.pkgs.callPackage;
	in {
		hms = pkgs.callPackage ./hms.nix {
			inherit pkgs;
		};

		brew = pkgs.callPackage ./homebrew.nix {};

		xonsh-direnv = pkgs.callPackage ./xonsh-direnv.nix {
			buildPythonPackage = pkgs.python3.pkgs.buildPythonPackage;
			fetchPypi = pkgs.python.pkgs.fetchPypi;
		};
	}
)
