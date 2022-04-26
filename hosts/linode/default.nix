{ ... }:

{
	imports = [
		./hardware-configuration.nix
		../../profiles/linode.nix
		./nextcloud.nix
		./nginx.nix
		./postgres.nix
		./synapse.nix
	];
	greg.home = false;
	networking.hostName = "linode";
	networking.domain = "thehellings.com";
}
