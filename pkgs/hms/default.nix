{ writeShellScriptBin, ... }:

writeShellScriptBin "hms" (builtins.readFile ./hms.sh)
