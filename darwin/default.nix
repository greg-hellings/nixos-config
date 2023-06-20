{ agenix, darwin, nixstable, nixunstable, overlays, hm, flake-utils, ... }:
let
	mac = {
		system ? "aarch64-darwin",
		name,
		channel ? nixunstable,
		extraMods ? []
	}:
	let
		nixpkgs = import channel {
			inherit system;
		};
	in darwin.lib.darwinSystem {
		inherit system;
		specialArgs = { inherit nixpkgs; };
		modules = [
			{ nixpkgs.overlays = overlays; }
			agenix.nixosModules.default
			hm.darwinModules.home-manager
			{
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users."gregory.hellings" = import ../home/home.nix;
				home-manager.extraSpecialArgs = {
					gnome = false;
					gui = true;
				};
			}
			../modules-all
			../modules-darwin
			./${name}
		] ++ extraMods;
	};
in rec {
	"C02G48H8MD6R" = mac { system = "x86_64-darwin"; name = "work"; };
	la23002 = mac { name = "ivr"; };
	LA23002 = la23002;
}
