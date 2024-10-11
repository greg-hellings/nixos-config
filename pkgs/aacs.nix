{ writeShellApplication, unzip, ... }:

writeShellApplication {
  name = "aacs";
  runtimeInputs = [ unzip ];
  text = ''
    [ ! -d "''${HOME}/.config/aacs" ] && mkdir -p "''${HOME}/.config/aacs"
    cd "''${HOME}/.config/aacs"
    [ -f KEYDB.cfg.zip ] && rm -f KEYDB.cfg.zip
    curl -L -o KEYDB.cfg.zip "http://fvonline-db.bplaced.net/fv_download.php?lang=eng"
    unzip KEYDB.cfg.zip
    mv keydb.cfg KEYDB.config
  '';
}
