{
  pkgs,
  nixvimunstable,
  ...
}:
let
  system = pkgs.system;
  vim = (
    nixvimunstable.legacyPackages.${system}.makeNixvim (
      import ./home/baseline/vim/config.nix {
        inherit pkgs;
        inherit (pkgs) lib;
        config.nixpkgs.config.allowUnfree = false; # I have tried to allow it, but I don't seem able to do so
      }
    )
  );
in
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      bashInteractive
      stdenv.cc
      curl
      git
      gnutar
      gzip
      inject
      inject-darwin
      nushell
      vim
      xonsh
      zellij
    ];
  };
}
