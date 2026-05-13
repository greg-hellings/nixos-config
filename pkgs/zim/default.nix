{ pkgs, lib, ... }:
let
  zimMetadata = builtins.fromJSON (builtins.readFile ./blobs.json);
  oneZim =
    sourceType: info:
    pkgs.callPackage ./one_zim.nix {
      inherit sourceType;
      sourceName = info.name;
      sourceHash = info.hash;
      sourceVersion = info.version;
    };
  # Preserves structure in the blobs.json file, turning leaves into drvs
  zimFileDrvs = builtins.mapAttrs (
    _language: types: (builtins.mapAttrs (sourceType: info: oneZim sourceType info) types)
  ) zimMetadata;
  # Flattens leaf drvs into the structure that flake packages expects
  zimFilePkgs = builtins.listToAttrs (
    lib.mapAttrsToListRecursiveCond (_path: x: !(x ? "name")) (_path: drv: {
      inherit (drv) name;
      value = drv;
    }) zimFileDrvs
  );
in
zimFilePkgs
