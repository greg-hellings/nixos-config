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
	greg.tailscale.enable = true;
	greg.backup.key = ./ssh/id_ed25519;
	networking.hostName = "linode";
	networking.domain = "thehellings.com";
}
