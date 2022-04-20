# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
		agenix.url = "github:ryantm/agenix";
		home-manager = {
			url = "github:nix-community/home-manager/release-21.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs:
	let
		mods = hostname: [
			inputs.agenix.nixosModule
			./profiles/base.nix
			./hosts/${hostname}
			inputs.home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.users.greg = import ./home/home.nix  "greg";
				home-manager.users.root = import ./home/home.nix  "root";
			}
		];

	in {
		nixosConfigurations = {
			"2maccabees" = inputs.nixpkgs.lib.nixosSystem {
				system = "aarch64-linux";
				specialArgs = inputs;
				modules = mods "2maccabees";
			};

			"linode" = inputs.nixpkgs.lib.nixosSystem {
			    system = "x86_64-linux";
			    specialArgs = inputs;
			    modules = mods "linode";
			};
		};
	};
}
