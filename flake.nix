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
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs:
	let
		mods = hostname: [
			inputs.agenix.nixosModule
			./modules
			./profiles/linux
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

		darwinMods = hostname: [
			inputs.agenix.nixosModule
			./profiles/darwin
			./hosts/${hostname}
		];

	in {
		nixosConfigurations = {
			"2maccabees" = machine "aarch64-linux" "2maccabees";

			"linode" = machine "x86_64-linux" "linode";

			"iso" = machine "x86_64-linux" "iso";
		};

		darwinConfigurations = {
			"C02G48H8MD6R" = inputs.darwin.lib.darwinSystem {
				system = "x86_64-darwin";
				specialArgs = inputs;
				modules = darwinMods "work";
			};
		};

		defaultPackage."x86_64-linux" = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
		defaultPackage."x86_64-darwin" = inputs.self.darwinConfigurations.C02G48H8MD6R.system;
	};
}
