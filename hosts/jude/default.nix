{ ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
		./virt.nix
	];
	networking.hostName = "jude";
	greg.gnome.enable= true;
}
