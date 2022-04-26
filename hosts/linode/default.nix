{ ... }:

{
	imports = [
		./hardware-configuration.nix
		./nextcloud.nix
		./nginx.nix
		./postgres.nix
		./synapse.nix
	];
	greg.home = false;
	greg.linode.enable = true;
	networking.hostName = "linode";
	networking.domain = "thehellings.com";
}
