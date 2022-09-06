{ ... }:

{
	imports = [
		./hardware-configuration.nix
	];
	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.efi.efiSysMountPoint = "/boot/efi";
	# Graphics, please
	greg.gnome.enable = true;
	# Set host name
	networking.hostName = "lappy";
}
