{ config, pkgs, lib, ... }:

let
	cfg = config.greg.gnome;

in with lib; {
	options = {
		greg.gnome.enable = mkEnableOption "Enable my default Gnome3 setup";
	};

	config = mkIf cfg.enable {
		# Sets up a basic Gnome installation
		services = {
			accounts-daemon.enable = true;

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
				gnome-browser-connector.enable = true;
				#chrome-gnome-shell.enable = true;
				sushi.enable = true;
				gnome-online-accounts.enable = true;
			};
		};

		programs.dconf.enable = true;
		xdg.portal = {
			enable = true;
			wlr.enable = true;  # Enables screen sharing in Wayland
		};

		# Used by gsconnect
		networking.firewall.allowedTCPPorts = [ 1716 ];

		# Enable some Gnome plugins that I like
		environment.systemPackages = with pkgs; [
			gnome3.adwaita-icon-theme
			gnome3.gnome-tweaks
			gnome3.dconf-editor
			gnomeExtensions.appindicator
			gnomeExtensions.clipboard-indicator
			gnomeExtensions.dash-to-dock
			gnomeExtensions.gsconnect
			gnomeExtensions.stocks-extension
			gnomeExtensions.tailscale-qs
			gnomeExtensions.vitals
		];
	};
}
