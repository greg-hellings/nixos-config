{ ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
	];
	networking.hostName = "jude";
	greg.gnome.enable= true;
}
