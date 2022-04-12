{ ... }:

{
	imports = [
		../../profiles/linode.nix
		./postgres.nix
	];
	networking.hostName = "linode";
}
