{ pkgs, config, lib, ... }:

{
	programs.xonsh = {
		enable = true;

		sessionVariables = {
			CLICOLOR = 1;
			EDITOR = "${pkgs.vim}/bin/vim";
			# vte_new_tab_cwd causes new Terminal tabs to open in the
			# same CWD as the current tab
			LESS_TERMCAP_mb = "\\033[01;31m";     # begin blinking
			LESS_TERMCAP_md = "\\033[01;31m";     # begin bold
			LESS_TERMCAP_me = "\\033[0m";         # end mode
			LESS_TERMCAP_so = "\\033[01;44;36m";  # begin standout-mode (bottom of screen)
			LESS_TERMCAP_se = "\\033[0m";         # end standout-mode
			LESS_TERMCAP_us = "\\033[00;36m";     # begin underline
			LESS_TERMCAP_ue = "\\033[0m";         # end underline
			LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN = "1";
			LSCOLORS = "ExGxBxDxCxEgEdxbxgxcxd";
			MAVEN_OPTS = " -Dmaven.wagon.http.ssl.insecure=true";
			OS_CLOUD = "default";
			PROMPT = "{vte_new_tab_cwd}{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {short_cwd}{branch_color}{curr_branch: {}}{RESET} {BOLD_BLUE}{prompt_end}{RESET} ";
			SWORD_PATH = "${config.home.homeDirectory}/.sword/";
			TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
			# Tells vox where to find virtualenvs
			VIRTUALENV_HOME = "${config.home.homeDirectory}/venv/";

			GOPATH = "${config.home.homeDirectory}/src/go";
			GOBIN  = "${config.home.homeDirectory}/src/bin";
		};

		aliases = {
			ac = "vox activate";

			cleanup = "sudo nix-collect-garbage --delete-older-than 30d && nix store optimise";
			d = "vox deactivate";
			dirflake = "nix flake new -t github:nix-community/nix-direnv";
			gh-personal = "$GH_CONFIG_DIR=\"${config.home.homeDirectory}/.config/gh/personal\" gh";
			gl-nging = "sudo nixos-container run gitlab -- systemctl restart nginx";
			ls = "ls --color";
			ll = "ls -l --color";
			molcol = "molecule -c ../../tests/molecule.yml";
			nixup = "nix flake lock --update-input";
			nixtest = "nixpkgs-review rev HEAD";
			pa = "cd ~/src/packaging";
			tf = "terraform";
			tsup = "sudo tailscale up";
			tspub = "sudo tailscale up --exit-node=linode";
			tshome = "sudo tailscale up --exit-node=2maccabees";
			tsclear = "sudo tailscale up --exit-node=''";
			vdown = "vagrant destroy";
			vhalt = "vagrant halt";
			vos = "vagrant up --provision --provider openstack";
			vprov = "vagrant provision";
			vup = "vagrant up --provision --provider libvirt";
			vssh = "vagrant ssh";
		};

		configHeader = builtins.readFile ./xonsh_header.xsh;
		configFooter = (builtins.readFile ./xonsh_footer.xsh) + (builtins.concatStringsSep "\n" [
			"with open('${pkgs.stdenv.cc}/nix-support/dynamic-linker', 'r') as fp:"
			"    $NIX_LD = fp.read().strip()"
		]);
	};
}
