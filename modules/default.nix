{ pkgs, lib, ... }:

let
	inherit (lib.strings) hasSuffix;
	system = pkgs.system; in
{
	imports = [
	]
	++ (if (lib.strings.hasSuffix "darwin" "nope") then [./darwin] else [])
	++ (if (lib.strings.hasSuffix "linux" "linux") then [./linux] else []);

	# Enable flakes
	nix = {
		package = pkgs.nixFlakes;
		gc = {
			automatic = true;
			# Scheduling of them is different in nixos vs nix-darwin, so check for
			# the extra details there
			options = "--delete-older-than 30d";
		};

		settings = {
			auto-optimise-store = (if lib.strings.hasSuffix "darwin" pkgs.system then false else true);
			experimental-features = "nix-command flakes";
			keep-outputs = true;
			keep-derivations = true;
			min-free = (toString (1024 * 1024 * 1024) );
			max-free = (toString (5 * 1024 * 1024 * 1024) );
			substituters = [
				"https://cache.garnix.io"
				"https://ai.cachix.org"
			];
			trusted-public-keys = [
				"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
				"ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
			];
		};
	};

	nixpkgs.config = {
		allowUnfree = true;
	};

	# Base packages that need to be in all my hosts
	environment.systemPackages = with pkgs; [
		agenix
		android-file-transfer
		bitwarden-cli
		diffutils
		git
		gh
		gnupatch
		gregpy
		findutils
		hms # My own home manager switcher
		htop
		killall
		nano
		pciutils
		pwgen
		transcrypt
		unzip
		wget
	];
}
