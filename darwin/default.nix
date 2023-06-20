{ agenix, darwin, nixstable, nixunstable, overlays, hm, ... }:
let
	mac = {
		system ? "aarch64-darwin",
		name,
		channel ? nixunstable,
		extraMods ? []
	}:
	let
		nixpkgs = channel;
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
				home-manager.users."gregory.hellings" = import ../home/home.nix {
					inherit (nixunstable) lib;
					pkgs = nixunstable;
					gui = true;
					gnome = false;
				};
			}
			../modules-all
			../modules-darwin
			./${name}
		] ++ extraMods;
	};
in {
	"C02G48H8MD6R" = mac { system = "x86_64-darwin"; name = "work"; };
	la23002 = mac { name = "ivr"; };
}
