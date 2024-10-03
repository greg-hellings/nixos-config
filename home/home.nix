{ pkgs, lib,
  host ? "most",
  nixvim,
  ...}:

{
	nixpkgs.config.allowUnfreePredicate = (_: true);
	imports = [
		nixvim.homeManagerModules.default
		./modules
	] ++ lib.optionals (builtins.pathExists ./hosts/${host}) [ ./hosts/${host} ];


	programs.tmux = {
		enable = true;
		keyMode = "vi";
		terminal = "xterm-256color";
		customPaneNavigationAndResize = true;
		extraConfig = (lib.strings.concatStringsSep "\n" [
			"bind P paste-buffer"
		]);
	};

	home.stateVersion = "23.05";
	home.packages = with pkgs; [
		bitwarden-cli
		copier
		diffutils
		findutils
		gh
		git
		gnupatch
		hms
		htop
		inetutils
		jq
		nano
		nix-prefetch
		nmap
		openssl
		setup-ssh
		tmux
		tree
		unzip
		wget
		zip
	];
}
