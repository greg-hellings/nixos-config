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

	mkhome = system: gui:
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
			configuration = import ./home.nix username {
				inherit pkgs gui;
				inherit (pkgs) config lib stdenv;
			};
		};
in {
	"aarch64-gui" = mkhome "aarch64-linux" true;
	"aarch64-nogui" = mkhome "aarch64-linux" false;
	"x86_64-gui" = mkhome "x86_64-linux" true;
	"x86_64-nogui" = mkhome "x86_64-linux" false;
	"x86_64-darwin" = mkhome "x86_64-darwin" true;
}
