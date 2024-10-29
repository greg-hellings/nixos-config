{ hooks, system, ... }:

{
  pre-commit-check = hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      deadnix.enable = true;
      # Needs https://github.com/DeterminateSystems/flake-checker/pull/130
      #flake-checker.enable = true;
      nixfmt-rfc-style.enable = true;
      check-merge-conflicts.enable = true;
    };
  };
}
