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
	greg.tailscale.enable = true;
	greg.gnome.enable= true;
}
