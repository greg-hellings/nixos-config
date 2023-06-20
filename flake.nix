# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		nixstable.url = "github:nixos/nixpkgs/nixos-23.05";
		nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
		agenix.url = "github:ryantm/agenix";
		flake-utils.url = "github:numtide/flake-utils";
		hm = {
			url = "github:nix-community/home-manager/release-23.05";
			inputs.nixpkgs.follows = "nixstable";
		};
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixunstable";
		};
		wsl = {
			url = "github:nix-community/NixOS-WSL";
			inputs.nixpkgs.follows = "nixunstable";
		};
		nurpkgs.url = "github:nix-community/NUR";
		ffmac.url = "github:bandithedoge/nixpkgs-firefox-darwin";
	};

	outputs = {nixstable, nixunstable, agenix, hm, nurpkgs, self, wsl, flake-utils, darwin, ...}@inputs:
	let
		pkg-sets = (
			final: prev: {
				unstable = import inputs.nixunstable { system = final.system; };
			}
		);
		local_overlay = import ./overlays;
		overlays = [
			agenix.overlays.default
			pkg-sets
			local_overlay
			nurpkgs.overlay
			inputs.ffmac.overlay
		];

	in {
		nixosConfigurations = (import ./hosts { inherit nixstable nixunstable overlays wsl agenix; });

		darwinConfigurations = (import ./darwin { inherit agenix darwin nixstable nixunstable overlays hm flake-utils; });

		defaultPackage = flake-utils.lib.eachDefaultSystemMap (system: inputs.self.homeConfigurations.gui."${system}".activationPackage);

		homeConfigurations = (
			import ./home {
				inherit nixunstable agenix hm overlays flake-utils;
				nixpkgs = nixunstable;
			}
		);

		overlays = { default = local_overlay; };
		modules = (import ./modules-all {}) //
		          (import ./modules-linux {}) //
		          (import ./modules-darwin {});
		packages = (import ./overlays/packages.nix { inherit nixunstable flake-utils; });
	};
}
