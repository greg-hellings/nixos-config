{ ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
		./printing.nix
		./virt.nix
	];
	networking.hostName = "jude";
	services.tailscale.enable = true;
	greg.gnome.enable= true;
}
