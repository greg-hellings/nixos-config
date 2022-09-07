{ pkgs, ... }:

{
	services.nix-daemon.enable = true;
	greg.darwin = true;
}
