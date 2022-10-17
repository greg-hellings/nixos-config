{ ... }:

let
	local_overlay = import ./overlays;
in {
	makeMachine =
		{system, name, pkgs,
		agenix ? import <agenix>,
		home-manager ? import <home-manager>}:
			let
				mods = hostname: [
					agenix.nixosModule
					./modules-all
					./modules-linux
					./hosts/${hostname}
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.extraSpecialArgs = {
							nixunstable = pkgs;
						};
					}
				];
			in (pkgs.lib.nixosSystem {
				inherit system;
				modules = (mods name);
				specialArgs = {
					nixpkgs = pkgs;
					agenix = agenix;
					home-manager = home-manager;
				};
			});
}
