{ pkgs, nixpkgs, lib, ... }:
{

	imports = [
		"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
	];

	networking.networkmanager.enable = lib.mkForce false;
}
