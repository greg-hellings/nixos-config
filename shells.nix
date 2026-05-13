{
  colmena,
  packages,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      bashInteractive
      colmena.defaultPackage.${system}
      stdenv.cc
      curl
      git
      gnutar
      gzip
      packages.inject
      packages.inject-darwin
      nano
    ];
  };
}
