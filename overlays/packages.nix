{ nixunstable, flake-utils }:

flake-utils.lib.eachDefaultSystemMap (system:
let
  pkgs = (import nixunstable { inherit system; });
in
{
  hms = pkgs.callPackage ./hms.nix {
    inherit pkgs;
  };

  brew = pkgs.callPackage ./homebrew.nix { };

  django-rapyd-modernauth = pkgs.python3.pkgs.callPackage ./django-rapyd-modernauth.nix {
    buildPythonPackage = pkgs.python3.pkgs.buildPythonPackage;
  };

  xonsh-direnv = pkgs.callPackage ./xonsh-direnv.nix {
    buildPythonPackage = pkgs.python3.pkgs.buildPythonPackage;
    fetchPypi = pkgs.python.pkgs.fetchPypi;
  };
}
)
