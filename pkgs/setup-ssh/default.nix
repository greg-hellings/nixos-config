{ writeShellApplication, gh, ... }:

writeShellApplication {
  name = "setup-ssh";
  runtimeInputs = [ gh ];
  text = builtins.readFile ./setup-ssh.sh;
}
