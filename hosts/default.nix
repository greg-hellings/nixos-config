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
		gnome ? false,
		gui ? false,
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
		specialArgs = { inherit nixpkgs inputs; };
		modules = [
			{
				nixpkgs.overlays = overlays;
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.greg = import ../home/home.nix;
				home-manager.extraSpecialArgs = {
					inherit gnome gui inputs overlays;
					home = "/home/greg";
					host = name;
				};
			}
			inputs.agenix.nixosModules.default
			hm.nixosModules.home-manager
			../modules-all
			../modules-linux
			./${name}
		] ++ extraMods;
	};
in {
	genesis = unstable { name = "genesis"; };
	jude = unstable {
		name = "jude";
		gnome = true;
		gui = true;
	};
	icdm-root = unstable { name = "icdm-root"; };
	linode = machine { name = "linode"; };
	mm = unstable { name = "mm"; };
	myself = unstable { name = "myself"; };
	iso = machine { name = "iso"; };
	iso-beta = unstable { name = "iso"; };
	# nix build '.#nixosConfigurations.wsl.config.system.build.installer'
	nixos = wsl { name = "wsl"; system = "aarch64-linux"; };
	# nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
	nixos-arm = wsl { name = "wsl"; system = "aarch64-linux"; };
}
