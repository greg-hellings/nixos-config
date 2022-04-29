# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
		nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
		agenix.url = "github:ryantm/agenix";
		home-manager = {
			url = "github:nix-community/home-manager/release-21.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nur.url = "github:nix-community/NUR";
	};

	outputs = inputs:
	let
		mods = hostname: [
			{ nixpkgs.overlays = [ inputs.nur.overlay ]; }
			inputs.agenix.nixosModule
			./modules
			./profiles/base
			./hosts/${hostname}
			inputs.home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.users.greg = import ./home/home.nix  "greg";
				home-manager.users.root = import ./home/home.nix  "root";
				home-manager.extraSpecialArgs = {
					nixunstable = inputs.nixunstable;
				};
			}
		];

		machine = system: name: inputs.nixpkgs.lib.nixosSystem {
			system = system;
			specialArgs = inputs;
			modules = mods name;
		};

	in {
		nixosConfigurations = {
			"2maccabees" = machine "aarch64-linux" "2maccabees";

			"linode" = machine "x86_64-linux" "linode";

			"jude" = machine "x86_64-linux" "jude";

			"iso" = machine "x86_64-linux" "iso";
		};

		defaultPackage."x86_64-linux" = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
	};
}
