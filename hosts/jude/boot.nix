{ lib, pkgs, ... }:

{
	# Use the systemd-boot EFI boot loader.
	boot = {
		binfmt.emulatedSystems = [ "aarch64-linux" ];
		kernelPackages = pkgs.linuxPackages_latest;
		supportedFilesystems = [ "ntfs" ];
		loader = {
			timeout = 15;
			systemd-boot = {
				enable = true;
				configurationLimit = 20;
				extraEntries = {
					"Windows.conf" = (lib.strings.concatStringsSep "\n" [
						"title Windows"
						"efi /EFI/Microsoft/EFI/bootmgfw.efi"
					]);
					"Win2.conf" = (lib.strings.concatStringsSep "\n" [
						"title Windows 11"
						"efi /shellx64.efi"
						"options -nointerrupt -noconsolein -noconsoleout windows11.nsh"
					]);
					"Shell.conf" = (lib.strings.concatStringsSep "\n" [
						"title EFI Shell"
						"efi /shell.efi"
					]);
				};
				extraFiles = {
					"windows11.nsh" = (pkgs.writeText "windows11.nsh" (lib.strings.concatStringsSep "\n" [
					]));
					"shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
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
