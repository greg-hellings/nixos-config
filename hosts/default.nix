{ inputs, overlays, ... }:
let
	wsl = args: (unstable (args // { extraMods = [ inputs.wsl.nixosModules.wsl ]; }));
	unstable = args: (machine (args // {
		channel = inputs.nixunstable;
		hm = inputs.hmunstable;
	}));
	machine = {
		channel ? inputs.nixstable,
		extraMods ? [],
		name,
		system ? "x86_64-linux",
		hm ? inputs.hm
	}:
	let
		nixpkgs = import channel {
			inherit system;
		};
	in channel.lib.nixosSystem {
		inherit system;
		specialArgs = { inherit nixpkgs inputs overlays; };
		modules = [
			{
				nixpkgs.overlays = overlays;
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.greg = import ../home/home.nix;
				home-manager.extraSpecialArgs = {
					inherit inputs overlays;
					home = "/home/greg";
					host = name;
				};
			}
			inputs.agenix.nixosModules.default
			hm.nixosModules.home-manager
			inputs.self.modules.nixosModule
			./${name}
		] ++ extraMods;
	};
in {
	genesis = machine { name = "genesis"; };
	exodus = unstable { name = "exodus"; };
	jude = unstable { name = "jude"; };
	icdm-root = unstable { name = "icdm-root"; };
	linode = machine { name = "linode"; };
	hosea = unstable { name = "hosea"; };
	jeremiah = unstable { name = "jeremiah"; };
	myself = unstable { name = "myself"; };
	iso = machine { name = "iso"; };
	iso-beta = unstable { name = "iso"; };
	# nix build '.#nixosConfigurations.wsl.config.system.build.installer'
	nixos = wsl { name = "wsl"; system = "aarch64-linux"; };
	# nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
	nixos-arm = wsl { name = "wsl"; system = "aarch64-linux"; };
}
