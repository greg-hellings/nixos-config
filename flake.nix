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
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixunstable";
		};
		nurpkgs.url = "github:nix-community/NUR";
	};

	outputs = {nixpkgs, nixunstable, agenix, home-manager, nurpkgs, self, ...}@inputs:
	let
		local_overlay = import ./overlays;
		overlays = [
			local_overlay
			nurpkgs.overlay
		];
		overlaid = system: import nixpkgs {
			inherit overlays system;
		};

		mods = hostname: [
			{ nixpkgs.overlays = overlays; }
			agenix.nixosModule
			./modules-all
			./modules-linux
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

		darwinMods = hostname: [
			{ nixpkgs.overlays = overlays; }
			inputs.agenix.nixosModule
			./modules-all
			./modules-darwin
			./hosts/${hostname}
		];

		unstableMachine = system: name: inputs.nixunstable.lib.nixosSystem {
			system = system;
			modules = mods name;
			specialArgs = {
				nixpkgs = inputs.nixunstable;
				nixunstable = inputs.nixunstable;
				agenix = inputs.agenix;
				home-manager = inputs.home-manager;
				nur = inputs.nur;
			};
		};

	in {
		nixosConfigurations = {
			"2maccabees" = unstableMachine "aarch64-linux" "2maccabees";

			"linode" = machine "x86_64-linux" "linode";

			"jude" = unstableMachine "x86_64-linux" "jude";

			"lappy" = machine "x86_64-linux" "lappy";

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

		homeConfigurations = (
			import ./home {
				inherit nixpkgs nixunstable agenix home-manager nurpkgs;
			}
		);

		overlays = local_overlay;
		modules = import [
			./modules-all
			./modules-linux
			./modules-darwin
		];
		packages = import ./overlays/packages.nix { pkgs = nixpkgs; };
	};
}
