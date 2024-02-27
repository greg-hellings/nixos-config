# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		agenix = {
			url = "github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixunstable";
		};
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixunstable";
		};
		flake-utils.url = "github:numtide/flake-utils";
		hm = {
			url = "github:nix-community/home-manager/release-23.11";
			inputs.nixpkgs.follows = "nixstable";
		};
		hmunstable = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixstable";
		};
		nixneovim.url = "github:NixNeovim/NixNeovim";
		nix23_05.url = "github:NixOS/nixpkgs/nixos-23.05";
		nixstable.url = "github:nixos/nixpkgs/nixos-23.11";
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
		flake-utils,
		hm,
		hmunstable,
		nixneovim,
		nix23_05,
		nixstable,
		nixunstable,
		nurpkgs,
		wsl,

		self,
		...}@inputs:
	let
		pkg-sets = final: prev: {
			unstable = import inputs.nixunstable { system = final.system; inherit overlays; };
			nix23_05 = import inputs.nix23_05 { system = final.system; inherit overlays; };
		};
		local_overlay = import ./overlays;
		overlays = [
			agenix.overlays.default
			pkg-sets
			local_overlay
			nixneovim.overlays.default
			nurpkgs.overlay
		];

	in {
		checks = {
			x86_64-linux = {
				unstable = self.nixosConfigurations.jude.config.system.build.toplevel;
				stable   = self.nixosConfigurations.linode.config.system.build.toplevel;
			};
		};

		nixosConfigurations = (import ./hosts { inherit inputs overlays; });

		darwinConfigurations = (import ./darwin { inherit inputs overlays; });

		homeConfigurations = (import ./home { inherit inputs overlays; });

		devShells = (flake-utils.lib.eachSystemMap flake-utils.lib.allSystems (system: let
			pkgs = import nixunstable { inherit system overlays; };
		in {
			default = pkgs.mkShell {
				buildInputs = with pkgs; [
					bashInteractive
					curl
					git
					gnutar
					gzip
					inject
					inject-darwin
					tmux
					vim
					xonsh
				];
			};
		}));

		overlays = {
			default = local_overlay;
			all = overlays;
		};

		modules = import ./modules;
		
		packages = {
			x86_64-linux = rec {
				default = iso;
				iso = self.nixosConfigurations.iso.config.system.build.isoImage;
				iso-beta = self.nixosConfigurations.iso-beta.config.system.build.isoImage;
			};
		};
	};
}
