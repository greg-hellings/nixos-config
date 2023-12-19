{ pkgs, ... }:

{
	imports = [
		./git.nix
		./hardware-configuration.nix
		./podman.nix
		./nextcloud.nix
		./nginx.nix
		./postgres.nix
		./synapse.nix
	];
	greg = {
		home = false;
		linode.enable = true;
		tailscale.enable = true;
	};
	networking = {
		hostName = "linode";
		domain = "thehellings.com";
		nameservers = [
			"100.88.91.27"
		];
	};
	environment.systemPackages = with pkgs; [
		bind
		forgejo
		gitea-actions-runner
		graphviz
		nix-du
	];
}
