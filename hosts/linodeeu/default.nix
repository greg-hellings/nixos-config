{ ... }:

{
	imports = [
		./hardware-configuration.nix
	];
	greg.home = false;
	greg.linode.enable = true;
	greg.tailscale.enable = true;
	networking.hostName = "linodeeu";
	networking.domain = "thehellings.com";
}
