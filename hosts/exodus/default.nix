{ pkgs, config, ... }:

{
	imports = [
		./hardware-configuration.nix
	];

	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	networking.hostName = "exodus";
	greg = {
		home = true;
		gnome.enable = true;
		print.enable = true;
		tailscale.enable = true;
		vmdev = {
			enable = true;
			system = "intel";
		};
	};
}
