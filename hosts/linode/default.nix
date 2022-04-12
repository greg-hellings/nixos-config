{ ... }:

{
	imports = [
		../../profiles/linode.nix
		./nginx.nix
		./postgres.nix
		./synapse.nix
	];
	networking.hostName = "linode";
	networking.domain = "thehellings.com";
}
