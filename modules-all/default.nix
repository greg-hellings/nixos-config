{ pkgs, ... }:

{
	# Enable flakes
	nix = {
		package = pkgs.nixFlakes;
		buildMachines = [
			{
				hostName = "dns.me.ts";
				system = "aarch64-linux";
			}

			{
				hostName = "jude.me.ts";
				system = "x86_64-linux";
			}
		];

		settings = {
			auto-optimise-store = true;
			experimental-features = "nix-command flakes";
			keep-outputs = true;
			keep-derivations = true;
			min-free = (toString (1024 * 1024 * 1024) );
			max-free = (toString (5 * 1024 * 1024 * 1024) );
			substituters = [
				"https://cache.garnix.io"
			];
			trusted-public-keys = [
				"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
			];
		};
	};

	nixpkgs.config = {
		allowUnfree = true;
		permittedInsecurePackages = [
			"qtwebkit-5.212.0-alpha4"
		];
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
