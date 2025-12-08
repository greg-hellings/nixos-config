{
  lib,
  system,
  top,
  ...
}:

let
  meta = import ./hosts/metadata.nix;
in
# Pulls all hosts down to be a check
(builtins.mapAttrs (_n: v: v.config.system.build.toplevel) (
  lib.filterAttrs (n: _v: builtins.any (a: a == system) meta.${n}.arch) top.self.nixosConfigurations
))
# Adds all packages as a check
// (top.self.packages.${system})
