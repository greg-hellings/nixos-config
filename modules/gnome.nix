{ config, pkgs, lib, ... }:

let
	cfg = config.greg.gnome;

in with lib; {
	options = {
		greg.gnome.enable = mkEnableOption "Enable my default Gnome3 setup";
	};

	config = mkIf cfg.enable {
		greg.xprograms.enable = true;

		# Sets up a basic Gnome installation
		services = {
			xserver = {
				enable = true;
				displayManager.gdm.enable = true;
				desktopManager.gnome.enable = true;
				layout = "us";
				# Trackpad support
				libinput.enable = true;
			};

			udev.packages = with pkgs; [
				gnome3.gnome-settings-daemon
			];

			pipewire.enable = true;

			# Enablement for Firefox
			gnome = {
				chrome-gnome-shell.enable = true;
				sushi.enable = true;
				gnome-online-accounts.enable = true;
			};
		};

		programs.dconf.enable = true;
		programs.sway.enable = true;  # Gives us Wayland
		xdg.portal = {
			enable = true;
			gtkUsePortal = true;
			wlr.enable = true;  # Enables screen sharing in Wayland
		};

		# Enable some Gnome plugins that I like
		environment.systemPackages = with pkgs; [
			gnome3.adwaita-icon-theme
			gnomeExtensions.appindicator
			gnomeExtensions.dash-to-dock
		];
	};
}
