{ config, pkgs, lib, ... }:

let
	gv = lib.hm.gvariant;
	cfg = config.greg.gnome;

in {
	options.greg.gnome = lib.mkEnableOption "Enable Gnome support and settings";

	config = (lib.mkIf cfg {
		programs.gnome-terminal = lib.mkIf ( pkgs.system != "x86_64-darwin") {
			enable = true;
			showMenubar = true;
			themeVariant = "dark";
			profile.default = {
				default = true;
				visibleName = "greg";
			};
		};

		dconf.settings = {
			"org/gnome/desktop/interface" = {
				clock-show-weekday = true;
			};
			"org/gnome/desktop/wm/keybindings" = {
				switch-applications = [];
				switch-applications-backward = [];
				switch-windows = ["<Alt>Tab"];
				switch-windows-backward = [ "<Shift><Alt>Tab" ];
			};
			"org/gnome/nautilus/preferences" = {
				default-folder-viewer = "icon-view";
				search-filter-time-type = "last_modified";
				search-view = "list-view";
			};
			"org/gnome/shell/window-switcher" = {
				app-icon-mode = "both";
				current-workspace-only = true;
			};
			"org/gnome/shell" = {
				favorite-apps = [
					"org.gnome.Calendar.desktop"
					"org.gnome.Nautilus.desktop"
					"org.gnome.Console.desktop"
					"firefox.desktop"
					"vlc.desktop"
				];
			};
			"org/gnome/shell/overrides" = {
				attach-modal-dialogs = true;
				dynamic-workspaces = true;
				edge-tiling = true;
				focus-change-on-pointer-rest = true;
				workspaces-only-on-primary = true;
			};
			"org/virt-manager/virt-manager/connections" = {
				autoconnect = [ "qemu://session" "qemu://system" ];
				uris = [ "qemu://session" "qemu://system" ];
			};
		};
	});
}
