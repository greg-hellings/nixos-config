{ config, lib, pkgs, ... }:

let
	cfg = config.greg.rpi4;

in with lib; {
	options = {
		greg.rpi4 = {
			enable = mkEnableOption "Enable support for Raspberry Pi 4s";
		};
	};

	config = mkIf cfg.enable {
		boot = {
			# This prevents us from having to compile our own kernel
			kernelPackages = pkgs.linuxPackages_rpi4;
			kernelParams = [
				"8250.nr_uarts=1"
				"console=ttyAMA0,115200"
				"console=tty1"
				"cma=128M"
			];

			loader = {
				raspberryPi = {
					enable = true;
					version = 4;
				};

				# Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
				grub.enable = false;

				# Enables the generation of /boot/extlinux/extlinux.conf
				#generic-extlinux-compatible.enable = true;
			};
		};

		environment.systemPackages = with pkgs; [
			raspberrypifw
			usbutils
		];
	};
}
