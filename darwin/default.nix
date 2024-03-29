{ inputs, overlays, ... }:
let
	mac = {
		system ? "aarch64-darwin",
		name,
		channel ? inputs.nixunstable,
		hm ? inputs.hmunstable,
		extraMods ? []
	}:
	let
		nixpkgs = import channel {
			inherit system overlays;
		};
	in inputs.darwin.lib.darwinSystem {
		inherit system;
		specialArgs = { inherit nixpkgs; };
		modules = [
			{
				nixpkgs.overlays = overlays;
				home-manager.extraSpecialArgs = {
					inherit inputs;
					host = name;
				};
			}
			hm.darwinModules.home-manager
			inputs.self.modules.darwinModule
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
