{ ... }:

{
	imports = [
		./automatic/nix.nix
		./automatic/programs.nix
		./automatic/syncthing.nix
		./automatic/users.nix
	];
	# I am a fan of network manager, myself
	networking.networkmanager.enable = true;
}
