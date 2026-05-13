{
  sourceType,
  sourceName,
  sourceVersion,
  sourceHash,

  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "zim-${sourceType}-${sourceName}.zim";
  version = sourceVersion;

  src = (
    fetchurl {
      url = "https://download.kiwix.org/zim/${sourceType}/${sourceName}_${sourceVersion}.zim";
      hash = sourceHash;
    }
    # fetchtorrent {
    #   inherit (val) hash;
    #   url = "https://download.kiwix.org/zim/${type}/${val.name}.torrent";
    #   backend = "transmission";
    #   postUnpack = "mkdir -p $downloadedDirectory/tmp; mv $downloadedDirectory/*.zim $downloadedDirectory/tmp";
    # }
  );
  phases = [ "installPhase" ];
  installPhase = ''
    set -x
    ln -s ${finalAttrs.src} $out
  '';
})
