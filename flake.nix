# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		stable.url = "github:nixos/nixpkgs/nixos-22.05";
		nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
		agenix.url = "github:ryantm/agenix";
		home-manager = {
			url = "github:nix-community/home-manager/release-22.05";
			inputs.nixpkgs.follows = "stable";
		};
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixunstable";
		};
		nurpkgs.url = "github:nix-community/NUR";
	};

	outputs = {stable, nixunstable, agenix, home-manager, nurpkgs, self, ...}@inputs:
	let
		local_overlay = import ./overlays;
		overlays = [
			agenix.overlay
			local_overlay
			nurpkgs.overlay
		];

		darwinMods = hostname: [
			{ stable.overlays = overlays; }
			inputs.agenix.nixosModule
			./modules-all
			./modules-darwin
			./hosts/${hostname}
		];

		machine = {
			system ? "x86_64-linux",
			name,
			channel ? stable
		}:
		let
			nixpkgs = channel;
		in nixpkgs.lib.nixosSystem {
			inherit system;
			modules = [
				{ nixpkgs.overlays = overlays; }
				agenix.nixosModule
				./modules-all
				./modules-linux
				./hosts/${name}
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.extraSpecialArgs = {
						inherit nixpkgs;
					};
				}
			];
			specialArgs = {
				home-manager = inputs.home-manager;
				inherit nixpkgs;
			};
		};

	in {
		nixosConfigurations = {
			"2maccabees" = machine {
				system = "aarch64-linux";
				name = "2maccabees";
				channel = nixunstable;
			};


			jude = machine {
				name = "jude";
				channel = nixunstable;
			};

			"linode" = machine { name = "linode"; };
			"lappy" = machine { name = "lappy"; };
			"iso" = machine { name = "iso"; };
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
				inherit nixunstable agenix home-manager nurpkgs;
				nixpkgs = nixunstable;
			}
		);

		overlays = local_overlay;
		modules = import [
			./modules-all
			./modules-linux
			./modules-darwin
		];
		packages = import ./overlays/packages.nix { pkgs = stable; };
	};
}
