{
  hooks,
  lib,
  system,
  ...
}:

{
  pre-commit-check = hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      deadnix.enable = true;
      # Needs https://github.com/DeterminateSystems/flake-checker/pull/130
      #flake-checker.enable = true;
      nixfmt-rfc-style.enable = true;
      check-merge-conflicts.enable = true;
      check-yaml.enable = true;
      yamllint = {
        enable = true;
        args = [
          "--config-data"
          (lib.generators.toYAML { } {
            extends = "default";
            ignore = [
              "manifests/cnpg-system/barman-cloud.yaml"
              ".pre-commit-config.yaml"
            ];
            rules = {
              comments = false;
              comments-indentation = false;
              document-start = false;
            };
          })
        ];
        verbose = true;
      };
    };
  };
}
