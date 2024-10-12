{
  callPackage,
  fetchtorrent,
  lib,
  stdenv,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs mapAttrsRecursiveCond;
  # Converts the inputs from the file into a fetchurl command
  zim =
    type: val:
    fetchtorrent {
      inherit (val) hash;
      url = "https://download.kiwix.org/zim/${type}/${val.name}.torrent";
      curlOptsList = [ "-L" ];
    };
  # Uses the function above to convert the JSON into a structure of fetchurl derivations
  zims = mapAttrs (_: types: (mapAttrs (type: hash: zim type hash) types)) (
    builtins.fromJSON (builtins.readFile ./zim/blobs.json)
  );
  # Turns the fetchurl derivations into a list of strings, copying the results into a final output
  copies = builtins.concatStringsSep "\n" (
    lib.attrsets.collect builtins.isString (
      mapAttrsRecursiveCond (as: !(lib.attrsets.isDerivation as)) # don't recurse derivations
        (_: v: "cp ${v} $out/") # copy derivation to destination
        zims
    )
  );
in
stdenv.mkDerivation {
  name = "zims";
  version = "2024-10";

  passthru = {
    inherit zims;
    updater = (callPackage ./zim/updater.nix { });
  };

  phases = [ "installPhase" ];

  # Collect all the zim files into a single folder derivation
  installPhase = ''
    mkdir -p $out
    echo "${copies}" > $out/derp.txt
  '';
}
