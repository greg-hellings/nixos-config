{
  lib,
  system,
  top,
  writeShellApplication,
  ...
}:

let
  meta = import ./hosts/metadata.nix;
in
# Pulls all hosts down to be a check
(builtins.mapAttrs
  (
    n: v:
    writeShellApplication {
      name = "build-${n}";
      runtimeInputs = [ ];
      text = ''
        nix build ".#${v.config.system.build.toplevel}"
      '';
    }
  )
  (lib.filterAttrs (n: _v: builtins.any (a: a == system) meta.${n}.arch) top.self.nixosConfigurations)
)
# Adds all packages as a check
// (top.self.packages.${system})
