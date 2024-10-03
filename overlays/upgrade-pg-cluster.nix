{ postgresql_15, postgresql_16, writeScriptBin, ... }:

let
  newPostgres = postgresql_16;
  oldPostgres = postgresql_15;
in
writeScriptBin "upgrade-pg-cluster" ''
  	set -eux
  	systemctl stop postgresql

  	export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
  	export NEWBIN="${newPostgres}/bin"

  	export OLDDATA="/var/lib/postgresql/${oldPostgres.psqlSchema}"
  	export OLDBIN="${oldPostgres}/bin"

  	install -d -m 0700 -o postgres -g postgres "$NEWDATA"
  	cd "$NEWDATA"
  	sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA"

  	sudo -u postgres "$NEWBIN/pg_upgrade" \
  	    --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
  	    --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
  	    "$@"
''
