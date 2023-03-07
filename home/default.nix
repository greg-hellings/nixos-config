{
	nixpkgs,
	overlays,
	home-manager,
	flake-utils,
	...
}:

let
	# I'm "greg" everywhere except Darwin where I'm "gregory.hellings"
	user = system:
		( if ( nixpkgs.lib.hasSuffix "-darwin" system ) then "gregory.hellings" else "greg" );
	home = system: username:
		if username == "root" then "/root" else
			( if ( nixpkgs.lib.hasSuffix "-darwin" system ) then "/Users/${username}" else "/home/${username}" );

	mkhome = {
		system,
		gui,
		gnome,
		username
	}:
		let
			homeDirectory = home system username;

			configDir = "${homeDirectory}/.config";

			pkgs = import nixpkgs {
				inherit overlays system;
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

in flake-utils.lib.eachDefaultSystem (system: {
	gui = mkhome {
		inherit system;
		gui = true;
		gnome = false;
		username = user system;
	};
	gdm = mkhome {
		inherit system;
		gui = true;
		gnome = true;
		username = user system;
	};
	cli = mkhome {
		inherit system;
		gui = false;
		gnome = false;
		username = user system;
	};
})
