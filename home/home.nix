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
		./ansible.nix
		./bash.nix
		./direnv.nix
		./git.nix
		./ssh.nix
		./vim.nix
		./xonsh.nix
		./hosts/${host}
	];


	programs.tmux = {
		enable = true;
		keyMode = "vi";
		shell = "${pkgs.xonsh}/bin/xonsh";
		terminal = "xterm-256color";
		customPaneNavigationAndResize = true;
			#"set-option -g default-command ${pkgs.xonsh}/bin/xonsh"
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
