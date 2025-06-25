{
  callPackage,
  fetchtorrent,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs mapAttrsRecursiveCond;
  # Converts the inputs from the file into a fetchtorrent command
  zim =
    type: val:
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit (val) name;
      src = (
        fetchtorrent {
          inherit (val) hash;
          url = "https://download.kiwix.org/zim/${type}/${val.name}.torrent";
          backend = "rqbit";
          postUnpack = "ls -lR";
        }
      );
      phases = [ "installPhase" ];
      installPhase = ''
        ls -lR ${finalAttrs.src}
        cp ${finalAttrs.src} $out
      '';
    });
  rawZims = builtins.fromJSON (builtins.readFile ./zim/blobs.json);
  # Uses the function above to convert the JSON into a structure of fetchtorrent derivations
  zims = mapAttrs (_: types: (mapAttrs (type: info: zim type info) types)) (rawZims);
  # Turns the fetchtorrent derivations into a list of strings, copying the results into a final output
  copies = builtins.concatStringsSep "\n" (
    lib.attrsets.collect builtins.isString (
      mapAttrsRecursiveCond (as: !(lib.attrsets.isDerivation as)) # don't recurse derivations
        (_: v: "ln -s ${v} $out/") # copy derivation to destination
        zims
    )
  );
in
stdenvNoCC.mkDerivation {
  name = "zims";
  version = "2024-10";

  passthru = {
    inherit zims rawZims;
    updater = (callPackage ./zim/updater.nix { });
  };

  phases = [ "installPhase" ];

  # Collect all the zim files into a single folder derivation
  installPhase = ''
    mkdir -p $out
    ${copies}
  '';
}
