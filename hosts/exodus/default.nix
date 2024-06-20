{ pkgs, config, ... }:

{
	imports = [
		./hardware-configuration.nix
		../jude/printing.nix
	];

	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	networking.hostName = "exodus";
	greg = {
		home = true;
		gnome.enable = true;
		tailscale.enable = true;
	};
}
