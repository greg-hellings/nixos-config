# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
	description = "Greg's machines!";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
		agenix.url = "github:ryantm/agenix";
	};

	outputs = inputs:
	let
		mods = hostname: [
			inputs.agenix.nixosModule
			./profiles/base.nix
			./hosts/${hostname}
		];
	in {
		nixosConfigurations = {
			"2maccabees" = inputs.nixpkgs.lib.nixosSystem {
				system = "aarch64-linux";
				specialArgs = {
					nixpkgs = inputs.nixpkgs;
					agenix = inputs.agenix;
				};
				modules = mods "2maccabees";
			};
		};
	};
}
