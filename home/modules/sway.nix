{ config, pkgs, lib, ... }:

let
	cfg = config.greg.sway;
	file_browser = {
		pkg = pkgs.krusader;
		path = "${pkgs.krusader}/bin/krusader";
	};
in {
	options.greg.sway = lib.mkEnableOption "Enable Sway support and settings";

	config = (lib.mkIf cfg {
		programs.swaylock.enable = true;

		wayland.windowManager.sway = let
			mod = config.wayland.windowManager.sway.config.modifier;
		in {
			enable = true;
			config = rec {
				#fonts.size = 10.0;
				keybindings = lib.mkOptionDefault {
					"Mod4+l" = "exec ${pkgs.swaylock}/bin/swaylock -c 000000";
					"Mod4+h" = "exec ${pkgs.qpwgraph}/bin/qpwgraph -x /home/greg/sound/headphones.qpwgraph -m";
					"Mod4+m" = "exec ${pkgs.qpwgraph}/bin/qpwgraph -x /home/greg/sound/monitor.qpwgraph -m";
					"Mod4+b" = "exec ${pkgs.qpwgraph}/bin/qpwgraph -x /home/greg/sound/both.qpwgraph -m";

					"${mod}+Shift+Return" = file_browser.path;
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
			file_browser.pkg
			p7zip
			plocate
			rpm
			qpwgraph
			xorg.xev
			xorg.xmodmap
			xxdiff
		];
	});
}
