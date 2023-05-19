{ ... }:

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
}
