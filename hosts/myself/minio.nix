{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		xfsprogs
	];

	fileSystems."/data/1" = {
		device = "/dev/disk/by-id/wwn-0x5000c500c48728e9-part1";
		fsType = "xfs";
	};
}
