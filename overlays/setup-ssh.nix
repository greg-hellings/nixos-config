{ pkgs, ... }:

pkgs.writeShellScriptBin "setup-ssh" (builtins.readFile ./setup-ssh.sh)
