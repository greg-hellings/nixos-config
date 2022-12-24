{
	nixpkgs,
	overlays,
	home-manager,
	username ? builtins.getEnv "USER",
	...
}:

let
	home = system:
		if username == "root" then "/root" else
			( if ( nixpkgs.lib.hasSuffix "-darwin" system ) then "/Users/${username}" else "/home/${username}" );

	mkhome = {
		system,
		gui,
		gnome
	}:
		let
			homeDirectory = home system;

			configDir = "${homeDirectory}/.config";

			pkgs = import nixpkgs {
				inherit overlays;
				config.allowUnfree = true;
				config.xdg.configHome = configDir;
			};

		in home-manager.lib.homeManagerConfiguration rec {
			inherit pkgs system username homeDirectory;
			stateVersion = "22.05";
			configuration = import ./home.nix {
				inherit pkgs gui gnome;
				inherit (pkgs) config lib stdenv;
			};
		};

	gdm = {
		gui = true;
		gnome = true;
	};

	cli = {
		gui = false;
		gnome = false;
	};

	gui = {
		gui = true;
		gnome = false;
	};

	arch = { system = "aarch64-linux"; };
	x86 = { system = "x86_64-linux"; };
	darwin = { system = "x86_64-darwin"; };
in {
	"wsl" = mkhome (gui // arch);
	"aarch64-gui" = mkhome (gdm // arch);
	"aarch64-nogui" = mkhome (cli // arch);
	"x86_64-gui" = mkhome (gdm // x86);
	"x86_64-nogui" = mkhome (cli // x86);
	"x86_64-darwin" = mkhome (gdm // darwin);
}
