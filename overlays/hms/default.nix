{ pkgs, ... }:

pkgs.writeShellScriptBin "hms" (builtins.readFile ./hms.sh)
