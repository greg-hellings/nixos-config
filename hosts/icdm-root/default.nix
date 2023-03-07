# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, agenix, ... }:

{
	imports = [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./boot.nix
		./filesystem.nix
		./location.nix
		./networking.nix
		./wiki.nix
	];

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.greg = {
		isNormalUser = true;
		description = "Gregory Hellings";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};
}
