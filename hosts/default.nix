{ inputs, overlays, ... }:
let
	wsl = args: (unstable (args // { extraMods = [ inputs.wsl.nixosModules.wsl ]; }));
	unstable = args: (machine (args // { channel = inputs.nixunstable; }));
	machine = {
		channel ? inputs.nixstable,
		extraMods ? [],
		gnome ? false,
		gui ? false,
		name,
		system ? "x86_64-linux"
	}:
	let
		nixpkgs = import channel {
			inherit system;
		};
	in channel.lib.nixosSystem {
		inherit system;
		specialArgs = { inherit nixpkgs; };
		modules = [
			{
				nixpkgs.overlays = overlays;
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.greg = import ../home/home.nix;
				home-manager.extraSpecialArgs = {
					inherit gnome gui inputs overlays;
					home = "/home/greg";
				};
			}
			inputs.agenix.nixosModules.default
			inputs.hm.nixosModules.home-manager
			../modules-all
			../modules-linux
			./${name}
		] ++ extraMods;
	};
in {
	"2maccabees" = unstable { name = "2maccabees"; system = "aarch64-linux"; };
	jude = unstable {
		name = "jude";
		gnome = true;
		gui = true;
	};
	icdm-root = unstable { name = "icdm-root"; };
	linode = machine { name = "linode"; };
	linodeeu = machine { name = "linodeeu"; };
	lappy = machine { name = "lappy"; };
	mm = unstable { name = "mm"; };
	iso = machine { name = "iso"; };
	# nix build '.#nixosConfigurations.wsl.config.system.build.installer'
	nixos = wsl { name = "wsl"; system = "aarch64-linux"; };
	# nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
	nixos-arm = wsl { name = "wsl"; system = "aarch64-linux"; };
}
