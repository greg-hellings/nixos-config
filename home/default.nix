{ nixpkgs, nurpkgs, home-manager, username ? builtins.getEnv "USER", ... }:

let
	homeDirectory = if username == "root" then "/root" else "/home/${username}";
	configDir = "${homeDirectory}/.config";

	pkgs = import nixpkgs {
		config.allowUnfree = true;
		config.xdg.configHome = configDir;
		overlays = [
			nurpkgs.overlay
			(import ../overlays)
		];
	};

	nur = import nurpkgs {
		inherit pkgs;
		nur = pkgs;
	};

	mkhome = system: gui:
		home-manager.lib.homeManagerConfiguration rec {
			inherit pkgs system username homeDirectory;
			stateVersion = "22.05";
			configuration = import ./home.nix username {
				inherit nur pkgs gui;
				inherit (pkgs) config lib stdenv;
			};
		};
in {
	"aarch64-gui" = mkhome "aarch64-linux" true;
	"aarch64-nogui" = mkhome "aarch64-linux" false;
	"x86_64-gui" = mkhome "x86_64-linux" true;
	"x86_64-nogui" = mkhome "x86_64-linux" false;
}
