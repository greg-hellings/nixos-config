{ config, pkgs, lib, ... }:

let
	cfg = config.greg.kde;

in with lib; {
	options = {
		greg.kde.enable = mkEnableOption "Enable my default KDE setup";
	};

	config = mkIf cfg.enable {
		# Sets up a basic KDE installation
		services = {
			xserver = {
				enable = true;
				displayManager.sddm.enable = true;
				desktopManager.plasma5.enable = true;
				layout = "us";
				# Trackpad support
				libinput.enable = true;
			};

			pipewire = {
				enable = true;
				alsa.enable = true;
				alsa.support32Bit = true;
				pulse.enable = true;
			};
		};

		programs.dconf.enable = true;
		programs.sway.enable = true;  # Gives us Wayland
		xdg.portal = {
			enable = true;
			wlr.enable = true;  # Enables screen sharing in Wayland
		};

		environment.systemPackages = with pkgs; [
			kalendar
			korganizer
			plasma-pa
		];
	};
}
