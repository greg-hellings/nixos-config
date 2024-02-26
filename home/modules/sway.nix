{ config, pkgs, lib, ... }:

let
	cfg = config.greg.sway;
in {
	options.greg.sway = lib.mkEnableOption "Enable Sway support and settings";

	config = (lib.mkIf cfg {
		programs.swaylock.enable = true;

		wayland.windowManager.sway = {
			enable = true;
			config = rec {
				#fonts.size = 10.0;
				keybindings = lib.mkOptionDefault {
					"Mod3+l" = "${pkgs.swaylock}/bin/swaylock";
				};
				modifier = "Mod1";
				output = {
					"Samsung Electric Company S24E650 H4ZN600985" = {
						mode = "1920x1200";
						transform = "90";
						pos = "0 0";
					};
					"ViewSonic Corporation VA2252 Series VMT201800925" = {
						mode = "1920x1080";
						pos = "200 1920";
					};
				};
				terminal = "${pkgs.alacritty}/bin/alacritty";
				startup = [
					{ command = "firefox"; }
				];
			};
			extraOptions = [
				"--unsupported-gpu"
			];
			extraSessionCommands = ''
				export WLR_NO_HARDWARE_CURSORS=1
			'';
			systemd.enable = true;
			wrapperFeatures = {
				base = true;
				gtk = true;
			};
		};
		
		home.pointerCursor = {
			name = "Adwaita";
			package = pkgs.gnome.adwaita-icon-theme;
			size = 12;
			x11 = {
				enable = true;
				defaultCursor = "Adwaita";
			};
		};

		home.packages = with pkgs; [
			arj
			dpkg
			kate
			kget
			krename
			krusader
			p7zip
			plocate
			rpm
			xxdiff
		];
	});
}
