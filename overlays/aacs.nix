{ pkgs, ... }:

pkgs.writeShellScriptBin "aacs" ''
  set -ex
  [ ! -d "''${HOME}/.config/aacs" ] && mkdir -p "''${HOME}/.config/aacs"
  cd "''${HOME}/.config/aacs"
  [ -f KEYDB.cfg.zip ] && rm -f KEYDB.cfg.zip
  curl -L -o KEYDB.cfg.zip "http://fvonline-db.bplaced.net/fv_download.php?lang=eng"
  ${pkgs.unzip}/bin/unzip KEYDB.cfg.zip
  mv keydb.cfg KEYDB.cfg''
