name: { pkgs, lib, gui, ...}:

let
	guiImports = if gui then
		[ ./gui ] else [];

	myPackages = pypackages: with pypackages; [
		pkgs.datadog-api-client
		pkgs.xonsh-direnv
		black
		datadog
		dateutil
		flake8
		ipython
		pyyaml
		responses
		ruamel-yaml
		tox
		typing-extensions
		virtualenv
	];

	myPython = pkgs.python3.withPackages myPackages;

in {
	imports = [
		./modules
		./ansible.nix
		./bash.nix
		./direnv.nix
		./git.nix
		./ssh.nix
		./vim.nix
		./xonsh.nix
	] ++ guiImports;


	programs.tmux = {
		enable = true;
		keyMode = "vi";
		shell = "${pkgs.xonsh}/bin/xonsh";
		terminal = "xterm-256color";
		customPaneNavigationAndResize = true;
		extraConfig = "set-option -g default-command ${pkgs.xonsh}/bin/xonsh";
	};

	home.stateVersion = "22.05";
	home.packages = with pkgs; [
		bitwarden-cli
		cdrtools
		diffutils
		ffmpeg
		findutils
		gh
		git
		gnupatch
		hms
		htop
		libtheora
		myPython
		nano
		openssl
		tmux
		transcrypt
		unzip
		wget
		x265
		yamllint
	];
}
