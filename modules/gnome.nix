{ config, pkgs, lib, ... }:

let
	cfg = config.greg.gnome;

in with lib; {
	options = {
		greg.gnome = mkEnableOption "Enable my default Gnome3 setup";
	};

	config = mkIf cfg {
		# Sets up a basic Gnome installation
		services.xserver = {
			enable = true;
			displayManager.gdm.enable = true;
			desktopManager.gnome.enable = true;
			layout = "us";
			# Trackpad support
			libinput.enable = true;
		};

		programs.dconf.enable = true;
		programs.sway.enable = true;  # Gives us Wayland
		xdg.portal.wlr.enable = true;  # Allows screen sharing in Wayland

		# Enable some Gnome plugins that I like
		environment.systemPackages = with pkgs; [
			gnome3.adwaita-icon-theme
			gnomeExtensions.appindicator
		];

		services.udev.packages = with pkgs; [
			gnome3.gnome-settings-daemon
		];
	};
}
