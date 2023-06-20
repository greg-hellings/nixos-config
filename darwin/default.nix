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
			inherit system overlays;
		};
	in darwin.lib.darwinSystem {
		inherit system;
		specialArgs = { inherit nixpkgs; };
		modules = [
			{ nixpkgs.overlays = overlays; }
			agenix.nixosModules.default
			hm.darwinModules.home-manager
			{
				home-manager = {
					useGlobalPkgs = true;
					users."gregory.hellings" = import ../home/home.nix;
					extraSpecialArgs = {
						gnome = false;
						gui = true;
						home = "/Users/gregory.hellings";
					};
				};
				users.users."gregory.hellings".home = "/Users/gregory.hellings";
			}
			../modules-all
			../modules-darwin
			./${name}
		] ++ extraMods;
	};
in rec {
	# Duplicate all the things, because nix-darwin does different things with case sensitivity
	# depending on where you live
	C02G48H8MD6R = mac { system = "x86_64-darwin"; name = "work"; };
	c02g48h8md6r = C02G48H8MD6R;

	la23002 = mac { name = "ivr"; };
	LA23002 = la23002;
}
