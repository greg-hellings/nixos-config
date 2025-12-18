{
  pkgs,
  colmena,
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
      inject
      inject-darwin
      nano
    ];
  };
}
