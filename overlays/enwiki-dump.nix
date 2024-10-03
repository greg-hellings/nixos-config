{ pkgs, ... }:

let
  version = "2022.07.20";
  date = builtins.replaceStrings [ "." ] [ "" ] version;

in
pkgs.writeShellScriptBin "wiki-data" ''
  set -eo pipefail

  function process_file {
  	file="''${lang}''${1}"
  	destfile=/var/tmp/''${file}
  	curl -C - -o "''${destfile}" "https://dumps.wikimedia.your.org/''${lang}wiki/${date}/''${file}"
  	bzcat "''${destfile}" | ${pkgs.php}/bin/php ${pkgs.mediawiki}/share/mediawiki/maintenance/importDump.php --report 500 | tee "/var/log/mediawiki-''${lang}-import"
  	rm "''${destfile}"
  }

  function zim_fetch {
  	dest="/srv/zims"
  	mkdir -p "''${dest}"
  	file="''${1}"
  	echo "Downloading ''${file}"
  	transmission-remote -w "''${dest}" -a https://download.kiwix.org/zim/''${file}.zim.torrent
  }

  #process_file "wiki-${date}-pages-articles-multistream.xml.bz2"
  #process_file "wiki-${date}-pages-meta-current.xml.bz2"
  #process_file "wiki-${date}-pages-articles.xml.bz2"

  zim_fetch wikipedia_en_all_maxi
  zim_fetch wikipedia_fr_all_maxi
  zim_fetch wikipedia_ht_all_maxi

  zim_fetch wiktionary_en_all_maxi
  zim_fetch wiktionary_fr_all_maxi

  zim_fetch wikiversity_en_all_maxi
  zim_fetch wikiversity_fr_all_maxi

  zim_fetch wikibooks_en_all_maxi
  zim_fetch wikibooks_fr_all_maxi

  zim_fetch wikisource_en_all_maxi
  zim_fetch wikisource_fr_all_maxi

  zim_fetch ted_en_science
  zim_fetch ted_en_technology

  zim_fetch phet_en
  zim_fetch phet_fr
  zim_fetch phet_ht

  zim_fetch gutenberg_en_all
  zim_fetch gutenberg_fr_all
''
