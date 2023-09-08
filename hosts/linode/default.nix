{ pkgs, ... }:

{
	imports = [
		./git.nix
		./hardware-configuration.nix
		./podman.nix
		./nextcloud.nix
		./nginx.nix
		./postgres.nix
		./rei.nix
		./synapse.nix
	];
	greg.home = false;
	greg.linode.enable = true;
	greg.tailscale.enable = true;
	networking.hostName = "linode";
	networking.domain = "thehellings.com";
	environment.systemPackages = with pkgs; [
		graphviz
		nix-du
	];
}
