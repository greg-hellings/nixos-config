name: { pkgs, lib, gui, ...}:

let
	guiImports = if gui then
		[ ./gui ] else [];

in {
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
	] ++ guiImports;


	programs.tmux = {
		enable = true;
		keyMode = "vi";
		shell = "${pkgs.xonsh}/bin/xonsh";
		terminal = "xterm-256color";
		customPaneNavigationAndResize = true;
		extraConfig = (lib.strings.concatStringsSep "\n" [
			"set-option -g default-command ${pkgs.xonsh}/bin/xonsh"
			"bind P paste-buffer"
		]);
	};

	home.stateVersion = "22.05";
	home.packages = with pkgs; [
		bazel
		bazel-buildtools
		bitwarden-cli
		cdrtools
		diffutils
		ffmpeg
		findutils
		gh
		git
		gnupatch
		gregpy
		hms
		htop
		jdk11
		jq
		libtheora
		nmap
		nano
		openssl
		tmux
		transcrypt
		unzip
		wget
		x265
		yamllint
		#yawsso
	];
}
