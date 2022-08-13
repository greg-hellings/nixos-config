# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
		nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
		agenix.url = "github:ryantm/agenix";
		home-manager = {
			url = "github:nix-community/home-manager/release-22.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nurpkgs.url = "github:nix-community/NUR";
	};

	outputs = {nixpkgs, nixunstable, agenix, home-manager, nurpkgs, self}@inputs:
	let
		local_overlay = import ./overlays;

		mods = hostname: [
			{ nixpkgs.overlays = [ nurpkgs.overlay local_overlay ]; }
			agenix.nixosModule
			./modules
			./hosts/${hostname}
			home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.extraSpecialArgs = {
					inherit nixunstable;
				};
			}
		];

		machine = system: name: nixpkgs.lib.nixosSystem {
			inherit system;
			specialArgs = inputs;
			modules = mods name;
		};

	in {
		nixosConfigurations = {
			"2maccabees" = machine "aarch64-linux" "2maccabees";

			"linode" = machine "x86_64-linux" "linode";

			"jude" = machine "x86_64-linux" "jude";

			"lappy" = machine "x86_64-linux" "lappy";

			"iso" = machine "x86_64-linux" "iso";
		};

		defaultPackage."x86_64-linux" = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;

		homeConfigurations = (
			import ./home {
				inherit nixpkgs nixunstable agenix home-manager nurpkgs;
			}
		);

		overlay = local_overlay;
		modules = import ./modules;
	};
}
