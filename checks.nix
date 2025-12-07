{
  hooks,
  lib,
  system,
  top,
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
// (builtins.mapAttrs (_n: v: v.config.system.build.toplevel) (
  lib.filterAttrs (_n: v: v.pkgs.stdenv.hostPlatform.system == system) top.self.nixosConfigurations
))
// (top.self.packages.${system})
