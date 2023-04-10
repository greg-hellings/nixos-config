{ pkgs, config, lib, ... }:

{
	programs.xonsh = {
		enable = true;

		sessionVariables = {
			TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
			CLICOLOR = 1;
			LSCOLORS = "ExGxBxDxCxEgEdxbxgxcxd";
			EDITOR = "${pkgs.vim}/bin/vim";
			# Tells vox where to find virtualenvs
			VIRTUALENV_HOME = "${config.home.homeDirectory}/venv/";
			# vte_new_tab_cwd causes new Terminal tabs to open in the
			# same CWD as the current tab
			PROMPT = "{vte_new_tab_cwd}{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {short_cwd}{branch_color}{curr_branch: {}}{RESET} {BOLD_BLUE}{prompt_end}{RESET} ";
			SWORD_PATH = "${config.home.homeDirectory}/.sword/";
			OS_CLOUD = "default";
			MAVEN_OPTS = " -Dmaven.wagon.http.ssl.insecure=true";
			LESS_TERMCAP_mb = "\\033[01;31m";     # begin blinking
			LESS_TERMCAP_md = "\\033[01;31m";     # begin bold
			LESS_TERMCAP_me = "\\033[0m";         # end mode
			LESS_TERMCAP_so = "\\033[01;44;36m";  # begin standout-mode (bottom of screen)
			LESS_TERMCAP_se = "\\033[0m";         # end standout-mode
			LESS_TERMCAP_us = "\\033[00;36m";     # begin underline
			LESS_TERMCAP_ue = "\\033[0m";         # end underline

			GOPATH = "${config.home.homeDirectory}/src/go";
			GOBIN  = "${config.home.homeDirectory}/src/bin";
		};

		aliases = {
			ac = "vox activate";

			cblack = "compass workspace run src/python3/uc/tools:run_black --";
			cbuild = "compass workspace build";
			cci = "./scripts/circleci-checks.py";
			cgh = "$GH_CONFIG_DIR=\"${config.home.homeDirectory}/.config/gh/compass\" gh";
			crun = "compass workspace run";
			ctest = "compass workspace test";
			cylint = "./scripts/run_yaml_lint.py";
			cpip = "compass workspace run src/python3/uc/tools:run_pip_compile";

			cleanup = "nix-collect-garbage -d && nix store optimise";
			d = "vox deactivate";
			devroles = "cd ~/src/ansible_collections/devroles";
			dirflake = "nix flake new -t github:nix-community/nix-direnv";
			gh-personal = "$GH_CONFIG_DIR=\"${config.home.homeDirectory}/.config/gh/personal\" gh";
			ls = "ls --color";
			ll = "ls -l --color";
			molcol = "molecule -c ../../tests/molecule.yml";
			nixup = "nix flake lock --update-input";
			pa = "cd ~/src/packaging";
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
		configFooter = builtins.readFile ./xonsh_footer.xsh;
	};
}
