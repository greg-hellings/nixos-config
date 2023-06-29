{ pkgs, ... }:

pkgs.writeShellScriptBin "inject-nixos-config" (builtins.readFile ./inject.sh)
