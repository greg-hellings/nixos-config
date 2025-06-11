{
  self',
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
    inherit (self'.checks.pre-commit-check) shellHook;
    buildInputs = with pkgs; [
      bashInteractive
      curl
      git
      gnutar
      gzip
      inject
      inject-darwin
      vim
      self'.checks.pre-commit-check.enabledPackages
      tmux
      xonsh
    ];
  };
}
