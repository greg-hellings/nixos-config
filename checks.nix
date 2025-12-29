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
in
homemanager // nixos // pkgs
