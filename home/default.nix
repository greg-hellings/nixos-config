{
	inputs,
	overlays,
	...
}:

let
	# I'm "greg" everywhere except Darwin where I'm "gregory.hellings"
	user = system:
		( if ( inputs.nixstable.lib.hasSuffix "-darwin" system ) then "gregory.hellings" else "greg" );
	home = system: username:
		if username == "root" then "/root" else
			( if ( inputs.nixstable.lib.hasSuffix "-darwin" system ) then "/Users/${username}" else "/home/${username}" );

	mkhome = {
		system,
		gui,
		gnome,
		username
	}:
		let
			stateVersion = "23.05";
			homeDirectory = home system username;
			cfg = { home = { inherit username homeDirectory stateVersion; }; };

			configDir = "${homeDirectory}/.config";

			pkgs = import inputs.nixstable {
				inherit overlays system;
				config.allowUnfree = true;
				config.xdg.configHome = configDir;
			};

		in inputs.hm.lib.homeManagerConfiguration rec {
			inherit pkgs;
			modules = [
				(import ./home.nix {
					inherit inputs pkgs gui gnome;
					inherit (pkgs) config lib stdenv;
				})
				cfg
			];
		};

in inputs.flake-utils.lib.eachDefaultSystem (system: {
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
