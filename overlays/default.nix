final: prev:

{
  ## Testing adding python packages in the correct manner
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (
      python-final: _:
      let
        cp = python-final.callPackage;
      in
      {
        daikinone = cp ./daikinone.nix { };
        xonsh-apipenv = cp ./xonsh-apipenv.nix { };
      }
    )
  ];

  qemu = prev.qemu.override { sdlSupport = true; };
  # Overrides of packages
  attic-client = prev.attic-client.overrideAttrs {
    patches = prev.attic-client.patches ++ [ ./attic-client.patch ];
  };
  libbluray-custom = prev.libbluray.override {
    withAACS = true;
    withBDplus = true;
  };
  handbrake = prev.handbrake.override { libbluray = final.libbluray-custom; };
  pipenv-ivr = prev.callPackage ./pipenv.nix { };
  OVMFFull = prev.OVMFFull.override {
    secureBoot = true;
    msVarsTemplate = true;
    tpmSupport = true;
  };
}
// (import ../pkgs { pkgs = prev; })
