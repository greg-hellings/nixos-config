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
      colmena.packages.${system}.default
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
