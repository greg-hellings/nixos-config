{ ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
	];
	networking.hostName = "jude";
	greg.gnome = true;
}
