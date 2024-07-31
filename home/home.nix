{ pkgs, lib,
  inputs,
  host ? "most",
  ...}:

let
	system = pkgs.system;
in
{
	imports = [
		inputs.nixvim.homeManagerModules.default
		./modules
	] ++ lib.optionals (builtins.pathExists ./hosts/${host}) [ ./hosts/${host} ];


	programs.tmux = {
		enable = true;
		keyMode = "vi";
		shell = "${pkgs.myxonsh}/bin/xonsh";
		terminal = "xterm-256color";
		customPaneNavigationAndResize = true;
			#"set-option -g default-command ${pkgs.myxonsh}/bin/xonsh"
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
