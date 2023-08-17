{ lib, ... }:

{
	# Use the systemd-boot EFI boot loader.
	#boot.loader.systemd-boot.enable = true;
	boot = {
		supportedFilesystems = [ "ntfs" ];
		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 10;
				extraEntries = {
					"Windows.conf" = (lib.strings.concatStringsSep "\n" [
						"title Windows"
						"efi /EFI/Windows/bootmgfw.efi"
					]);
				};
			};
			grub = {
				enable = false;
				device = "/dev/nvme0n1";
				useOSProber = true;
				efiSupport = true;
				extraEntries = ''
				menuentry "Windows" --class windows --class os {
				  insmod ntfs
				  chainloader (hd0,0)/EFI/Windows/bootmgfw.efi
				}
				'';
			};
			#efi.canTouchEfiVariables = true;
		};
	};
	networking.interfaces.enp4s0.useDHCP = true;
}
