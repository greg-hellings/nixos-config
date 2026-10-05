{
  lib,
  self',
  system,
  top,
  ...
}:

let
  nixos = lib.mapAttrs' (n: v: lib.nameValuePair "nixos-${n}" v.config.system.build.toplevel) (
    lib.filterAttrs (_: v: v.pkgs.stdenv.hostPlatform.system == system) top.self.nixosConfigurations
  );
  homemanager = lib.mapAttrs' (n: v: lib.nameValuePair "hm-${n}" v.activationPackage) (
    lib.filterAttrs (_: v: v.pkgs.stdenv.hostPlatform.system == system) top.self.homeConfigurations
  );
  pkgs = lib.mapAttrs' (n: v: lib.nameValuePair "pkg-${n}" v) self'.packages;
  shells = lib.mapAttrs' (n: v: lib.nameValuePair "shell-${n}" v) self'.devShells;
in
homemanager // nixos // pkgs // shells
