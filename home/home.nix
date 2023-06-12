{ pkgs, lib, gui, gnome,
  inputs,
  ...}:

{
	imports = [
		inputs.nixneovim.nixosModules.default
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
		brew
		diffutils
		dmidecode
		findutils
		gimp
		git
		gnupatch
		gregpy
		hms
		htop
		inetutils
		jq
		nano
		nmap
		openssl
		setup-ssh
		tmux
		transcrypt
		tree
		unzip
		vagrant
		wget
	];
}
