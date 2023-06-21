# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		agenix.url = "github:ryantm/agenix";
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixunstable";
		};
		ffmac.url = "github:bandithedoge/nixpkgs-firefox-darwin";
		flake-utils.url = "github:numtide/flake-utils";
		hm = {
			url = "github:nix-community/home-manager/release-23.05";
			inputs.nixpkgs.follows = "nixstable";
		};
		nixneovim.url = "github:NixNeovim/NixNeovim";
		nixstable.url = "github:nixos/nixpkgs/nixos-23.05";
		nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
		nurpkgs.url = "github:nix-community/NUR";
		wsl = {
			url = "github:nix-community/NixOS-WSL";
			inputs.nixpkgs.follows = "nixunstable";
		};
	};

	outputs = {
		agenix,
		darwin,
		ffmac,
		flake-utils,
		hm,
		nixneovim,
		nixstable,
		nixunstable,
		nurpkgs,
		wsl,

		self,
		...}@inputs:
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
			nixneovim.overlays.default
			nurpkgs.overlay
			ffmac.overlay
		];

	in {
		nixosConfigurations = (import ./hosts { inherit inputs overlays; });

		darwinConfigurations = (import ./darwin { inherit inputs overlays; });

		defaultPackage = flake-utils.lib.eachDefaultSystemMap (system: inputs.self.homeConfigurations.gui."${system}".activationPackage);

		homeConfigurations = (
			import ./home {
				inherit inputs overlays;
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
