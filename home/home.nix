{ pkgs, lib, gui, gnome, ...}:

{
	imports = [
		./modules
		./ansible.nix
		./bash.nix
		./direnv.nix
		./git.nix
		./ssh.nix
		./templates.nix
		./vim.nix
		./xonsh.nix
	] ++ ( if gui then [ ./gui ] else []);


	greg.gnome = gnome;

	programs.tmux = {
		enable = true;
		keyMode = "vi";
		shell = "~/.nix-profile/bin/xonsh";
		terminal = "xterm-256color";
		customPaneNavigationAndResize = true;
		extraConfig = (lib.strings.concatStringsSep "\n" [
			"set-option -g default-command ~/.nix-profile/bin/xonsh"
			"bind P paste-buffer"
		]);
	};

	home.stateVersion = "22.05";
	home.packages = with pkgs; [
		bitwarden-cli
		diffutils
		findutils
		git
		gnupatch
		gregpy
		hms
		htop
		jq
		nano
		nmap
		openssl
		setup-ssh
		tmux
		transcrypt
		unzip
		wget
	];
}
