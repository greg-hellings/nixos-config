{ self', pkgs, nixvimunstable, ... }:
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
      (nixvimunstable.legacyPackages.${system}.makeNixvim (import ./home/modules/baseline/vim/config.nix { inherit pkgs; inherit (pkgs) lib; }))
      self'.checks.pre-commit-check.enabledPackages
      tmux
      xonsh
    ];
  };
}
