{ agenix, darwin, nixstable, nixunstable, overlays, ... }:
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
			agenix.nixosModule
			../modules-all
			../modules-darwin
			./${name}
		] ++ extraMods;
	};
in {
	"C02G48H8MD6R" = mac { system = "x86_64-darwin"; name = "work"; };
	la23002 = mac { name = "ivr"; };
}
