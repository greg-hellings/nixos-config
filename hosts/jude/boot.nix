{ lib, ... }:

{
	# Use the systemd-boot EFI boot loader.
	boot = {
		supportedFilesystems = [ "ntfs" ];
		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 10;
				extraEntries = {
					"Windows.conf" = (lib.strings.concatStringsSep "\n" [
						"title Windows"
						"efi /EFI/Microsoft/EFI/bootmgfw.efi"
					]);
					"Pop.conf" = (lib.strings.concatStringsSep "\n" [
						"title Pop!_OS"
						"linux /EFI/Pop_OS-e4918d10-538d-42ad-b35d-a1ee2ed2a433/vmlinuz.efi"
						"initrd /EFI/Pop_OS-e4918d10-538d-42ad-b35d-a1ee2ed2a433/initrd.img"
						"options root=UUID=e4918d10-538d-42ad-b35d-a1ee2ed2a433 ro quiet loglevel=0 systemd.show_status=false splash"
					]);
					"Pop-oldkern.conf" = (lib.strings.concatStringsSep "\n" [
						"title Pop!_OS"
						"linux /EFI/Pop_OS-e4918d10-538d-42ad-b35d-a1ee2ed2a433/vmlinuz-previous.efi"
						"initrd /EFI/Pop_OS-e4918d10-538d-42ad-b35d-a1ee2ed2a433/initrd.img-previous"
						"options root=UUID=e4918d10-538d-42ad-b35d-a1ee2ed2a433 ro quiet loglevel=0 systemd.show_status=false splash"
					]);
					"Pop-recovery.conf" = (lib.strings.concatStringsSep "\n" [
						"title Pop!_OS Recovery"
						"linux /EFI/Recovery-1E97-BC0F/vmlinuz.efi"
						"initrd /EFI/Recovery-1E97-BC0F/initrd.gz"
						"options boot=casper hostname=recovery userfullname=Recovery username=recovery live-media-path=/casper-1E97-BC0F noprompt "
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
}
