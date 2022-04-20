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
			./modules
			./profiles/base.nix
			./hosts/${hostname}
			inputs.home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.users.greg = import ./home/home.nix  "greg";
				home-manager.users.root = import ./home/home.nix  "root";
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
		};
	};
}
