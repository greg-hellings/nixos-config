{ ... }:

{
	imports = [
		./automatic
		./backup.nix
		./gnome.nix
		./home.nix
		./linode.nix
		./linux.nix
		./proxy.nix
		./rpi4.nix
		./tailscale.nix
	];

	system.stateVersion = "22.05";

	# I am a fan of network manager, myself
	networking.networkmanager.enable = true;

	nix.settings.auto-optimise-store = true;
}
