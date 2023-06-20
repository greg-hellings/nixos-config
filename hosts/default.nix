{ nixstable, nixunstable, overlays, wsl, agenix, ... }:
let
	wsl = args: (unstable (args // { extraMods = [ wsl.nixosModules.wsl ]; }));
	unstable = args: (machine (args // { channel = nixunstable; }));
	machine = {
		system ? "x86_64-linux",
		name,
		channel ? nixstable,
		extraMods ? []
	}:
	let
		nixpkgs = channel;
	in nixpkgs.lib.nixosSystem {
		inherit system;
		modules = [
			{ nixpkgs.overlays = overlays; }
			agenix.nixosModules.default
			../modules-all
			../modules-linux
			./${name}
		] ++ extraMods;
		specialArgs = { inherit nixpkgs; };
	};
in {
	"2maccabees" = unstable { system = "aarch64-linux"; name = "2maccabees"; };
	jude = unstable { name = "jude"; };
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
