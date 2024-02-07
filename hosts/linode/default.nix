{ pkgs, lib, ... }:

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

	programs.ssh.extraConfig = lib.strings.concatStringsSep "\n" [
		"Host chronicles.shire-zebra.ts.net"
		"    User backup"
		"    IdentityFile /etc/ssh/backup_ed25519"
		"    StrictHostKeyChecking no"
		"    UserKnownHostsFile /dev/null"
	];

	networking = {
		hostName = "linode";
		domain = "thehellings.com";
		nameservers = [
			"100.88.91.27"
		];
	};

	environment.systemPackages = with pkgs; [
		bind
		graphviz
		nix-du
	];
}
