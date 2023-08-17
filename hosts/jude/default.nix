{ pkgs, ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
		./printing.nix
		./virt.nix
	];
	programs.steam.enable = true;
	networking.hostName = "jude";
	networking.enableIPv6 = false;
	#systemd.oomd.enable = false;
	greg.tailscale.enable = true;
	greg.gnome.enable = true;
	greg.kde.enable = false;

	environment.systemPackages = with pkgs; [
		oathToolkit
	];
	fileSystems =  {
		"/boot" = {
			device = "/dev/nvme0n1p1";
			fsType = "auto";
		};
		"/windows" = {
			device = "/dev/nvme0n1p3";
			fsType = "ntfs-3g";
		};
	};
}
