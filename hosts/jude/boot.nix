{ ... }:

{
	# Use the systemd-boot EFI boot loader.
	#boot.loader.systemd-boot.enable = true;
	boot.loader.grub.device = "/dev/nvme0n1";
	boot.loader.grub.useOSProber = false;
	boot.loader.grub.extraEntries = ''
		menuentry "Windows" --class windows --class os {
		  insmod nfts
		  search --no-floppy --set=root --fs-uuid A41B-5963
		  chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
		}
	'';
	boot.loader.efi.canTouchEfiVariables = true;
	networking.interfaces.enp4s0.useDHCP = true;
}
