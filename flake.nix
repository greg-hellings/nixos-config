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
		btc = {
			url = "github:fort-nix/nix-bitcoin/release";
		};
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixunstable";
		};
		flake-utils.url = "github:numtide/flake-utils";
		hm = {
			url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixstable";
		};
		hmunstable = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixstable";
		};
		nixvimstable.url = "github:nix-community/nixvim/nixos-24.05";
		nixvimunstable.url = "github:nix-community/nixvim/main";
		nix23_05.url = "github:NixOS/nixpkgs/nixos-23.05";
		nixstable.url = "github:nixos/nixpkgs/nixos-24.05";
		nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
		nurpkgs.url = "github:nix-community/NUR";
		vsext.url = "github:nix-community/nix-vscode-extensions";
		wsl = {
			url = "github:nix-community/NixOS-WSL";
			inputs.nixpkgs.follows = "nixunstable";
		};
		zed.url = "github:zed-industries/zed/v0.154.x";
	};

	outputs = {
		agenix,
		flake-utils,
		nixunstable,
		nurpkgs,
		vsext,

		self,
		...}@inputs:
	let
		local_overlay = import ./overlays;
		overlays = [
			agenix.overlays.default
			local_overlay
			nurpkgs.overlay
			vsext.overlays.default
			(_: _: { zed-editor = inputs.zed.packages.x86_64-linux.default; } )
		];

	in {
		#checks = {
		#	x86_64-linux = {
		#		unstable = self.nixosConfigurations.jude.config.system.build.toplevel;
		#		stable   = self.nixosConfigurations.linode.config.system.build.toplevel;
		#	};
		#	aarch64-linux = {
		#		unstable = self.nixosConfigurations.nixos.config.system.build.toplevel;
		#	};
		#};

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
		};

		modules = import ./modules;
		
		packages = {
			x86_64-linux = rec {
				default = iso-beta;
				iso = self.nixosConfigurations.iso.config.system.build.isoImage;
				iso-beta = self.nixosConfigurations.iso-beta.config.system.build.isoImage;
			};
		};
	};
}
