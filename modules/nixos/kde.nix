{ config, pkgs, lib, options, ... }:

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
				displayManager = {
					defaultSession = "plasma";
					sddm.enable = true;
				};
				xkb.layout = "us";
				# Trackpad support
				libinput.enable = true;
			} // (optionalAttrs (builtins.hasAttr "plasma6" options.services.xserver.desktopManager) {
				desktopManager.plasma6.enable = true;
			});

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
