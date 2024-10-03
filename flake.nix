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
		flake-parts.url = "github:hercules-ci/flake-parts";
		hooks.url = "github:cachix/git-hooks.nix";
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

	outputs = { self, ...}@inputs: let
		local_overlay = import ./overlays;
		overlays = [
			inputs.agenix.overlays.default
			local_overlay
			inputs.nurpkgs.overlay
			inputs.vsext.overlays.default
			(_: _: { zed-editor = inputs.zed.packages.x86_64-linux.default; } )
		];

	in inputs.flake-parts.lib.mkFlake { inherit inputs; } {
		systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
		#checks = {
		#	x86_64-linux = {
		#		unstable = self.nixosConfigurations.jude.config.system.build.toplevel;
		#		stable   = self.nixosConfigurations.linode.config.system.build.toplevel;
		#	};
		#	aarch64-linux = {
		#		unstable = self.nixosConfigurations.nixos.config.system.build.toplevel;
		#	};
		#};

		flake = {
			nixosConfigurations = (import ./hosts { inherit inputs overlays; });

			darwinConfigurations = (import ./darwin { inherit inputs overlays; });

			homeConfigurations = (import ./home { inherit inputs overlays; });

			overlays = {
				default = local_overlay;
			};

			modules = import ./modules;
		};

		perSystem = { config, self', pkgs', system, ... }: {
			_module.args.pkgs = import inputs.nixpkgs {
				inherit system overlays;
			};

			devShells = {
				default = pkgs'.mkShell {
					buildInputs = with pkgs'; [
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
			};

			packages = rec {
				defaullt = iso;
				iso = self.nixosConfigurations.iso.config.system.build.isoImage;
				iso-beta = self.nixosConfigurations.iso-beta.config.system.build.isoImage;
			};
		};
	};
}
