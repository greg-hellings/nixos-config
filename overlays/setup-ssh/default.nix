{ pkgs, gh, ... }:

pkgs.writeShellScriptBin "setup-ssh" (builtins.replaceStrings [ "gh " ] [ "${gh}/bin/gh " ] (builtins.readFile ./setup-ssh.sh))
