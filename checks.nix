{ hooks, system, ... }:

{
  pre-commit-check = hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      deadnix.enable = true;
      # Needs https://github.com/DeterminateSystems/flake-checker/pull/130
      #flake-checker.enable = true;
      nixpkgs-fmt.enable = true;
    };
  };
}
