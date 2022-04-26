{ config, lib, pkgs, ... }:

let
	cfg = config.greg.linode;

in with lib;
{
	options.greg.linode = {
		enable = mkEnableOption "Set sensible defaults for a Linode host";

		bootTimeout = mkOption {
			type = types.int;
			default = 15;
			description = "Set bootloader timeout in seconds.";
		};
	};

	config = mkIf cfg.enable {
		# Enables connection over Linode consoles
		boot.kernelParams = [ "console=ttyS0,19200n8" ];
		boot.loader.grub = {
			device = "nodev";
			extraConfig = ''
serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
terminal_input serial;
terminal_output serial;
'';
		};

		# Tells grub to ignore partion-free device warnings, since we are on Linode
		boot.loader.timeout = 15;

		networking.usePredictableInterfaceNames = false;  # Use old style eth0 names
		networking.useDHCP = false;
		networking.interfaces.eth0.useDHCP = true;

		# Suggested diagnostic tools
		environment.systemPackages = with pkgs; [
			inetutils
			mtr
			sysstat
		];
	};
}
