{ ... }:

{
	# Use the systemd-boot EFI boot loader.
	#boot.loader.systemd-boot.enable = true;
	boot.loader.grub.device = "/dev/nvme0n1";
	boot.loader.efi.canTouchEfiVariables = true;
	networking.interfaces.enp4s0.useDHCP = true;
}
