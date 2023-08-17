{ ... }:

{
	#fileSystems."/boot/efi" = {
	#	device = "/dev/by-uuid/9466C36266C34428";
	#	fsType = "auto";
	#};
	# Use the systemd-boot EFI boot loader.
	#boot.loader.systemd-boot.enable = true;
	boot = {
		supportedFilesystems = [ "ntfs" ];
		loader = {
			grub = {
				device = "/dev/nvme0n1";
				useOSProber = true;
				extraEntries = ''
				menuentry "Windows" --class windows --class os {
		  	  	  insmod ntfs
		  	  	  chainloader (hd0,2)/Windows/Boot/EFI/bootmgfw.efi
				}
				'';
			};
			efi.canTouchEfiVariables = true;
		};
	};
	networking.interfaces.enp4s0.useDHCP = true;
}
