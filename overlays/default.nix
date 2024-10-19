_final: prev:

let
  myPackages =
    pypackages: with pypackages; [
      black
      dateutil
      ipython
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

in
rec {
  gregpy = myPython;

  ## Testing adding python packages in the correct manner
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (
      python-final: _:
      let
        cp = python-final.callPackage;
      in
      {
        xonsh-apipenv = cp ./xonsh-apipenv.nix { };
      }
    )
  ];

  # My own packages
  enwiki-dump = prev.callPackage ./enwiki-dump.nix { };

  # Overrides of packages
  libbluray-custom = prev.libbluray.override {
    withAACS = true;
    withBDplus = true;
  };
  handbrake = prev.handbrake.override { libbluray = libbluray-custom; };
  pipenv-ivr = prev.callPackage ./pipenv.nix { };
}
