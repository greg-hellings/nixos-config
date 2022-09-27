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
		};

		aliases = {
			ac = "vox activate";
			cblack = "compass workspace run src/python3/uc/tools:run_black --";
			cci = "./scripts/circleci-checks.py";
			crun = "compass workspace run";
			cylint = "./scripts/run_yaml_lint.py";
			d = "vox deactivate";
			devroles = "cd ~/src/ansible_collections/devroles";
			dirflake = "nix flake new -t github:nix-community/nix-direnv";
			ll = "ls -l";
			molcol = "molecule -c ../../tests/molecule.yml";
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

		configHeader = ''
if  '__NIX_DARWIN_SET_ENVIRONMENT_DONE' not in ''${...} or not $__NIX_DARWIN_SET_ENVIRONMENT_DONE:
    source-bash /etc/bashrc

# set -e == $RAISE_SUBPROC_ERROR = True
# set -x == trace on; $XONSH_TRACE_SUBPROC = True
# $? == _.rtn

import os

xontrib load direnv
'';

#$PKG_CONFIG_PATH = '/usr/local/lib/pkgconfig'
#$GOPATH = $HOME + '/.go'
#$JAVA_HOME = '/etc/alternatives/java_sdk'
		configFooter = ''
def _rebuild(args):
    import os
    system = os.uname()
    if system.sysname == 'Darwin':
        darwin-rebuild --flake ~/.config/nix switch
    else:
        sudo nixos-rebuild switch

def _yaml2json(args, stdin=None, stdout=None):
    import sys, yaml, json
    from yaml import CLoader
    json.dump(yaml.load(stdin, Loader=CLoader), stdout, indent=4)

def _py2env(args):
    vox new @(args[0]) -p /usr/bin/python2

def _py3env(args):
    vox new @(args[0])

def _rundock(args):
    if os.path.exists('/usr/bin/podman'):
        e = 'podman'
    else:
        e = 'docker'
    @(e) exec -ti @(args[0]) /bin/bash

def _pip_extras(args):
    import importlib_metadata
    print(importlib_metadata.metadata(args[0]).get_all('Provides-Extra'))

# Container stuff
def _newdock(args):
    if os.path.exists('/usr/bin/podman'):
        e = 'podman'
    else:
        e = 'docker'
    @(e) run -P --privileged=true -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v @(os.getcwd()):/dmnt -v /etc/pki:/etc/pki:ro -d --name @(args[1]) @(args[0]) /sbin/init
    rundock @(args[1])

def _unknown_host(args):
    sed -i -e @(args[0])d ~/.ssh/known_hosts

aliases['rebuild'] = _rebuild
aliases['yaml2json'] = _yaml2json
aliases['py2env'] = _py2env
aliases['py3env'] = _py3env
aliases['rundock'] = _rundock
aliases['newdock'] = _newdock
aliases['unknown_host'] = _unknown_host
aliases['pip_extras'] = _pip_extras
###
#
# Other random nice-to-have things
#
###

# Does virtualenv support
xontrib load vox
# Faster coreutils
xontrib load coreutils

# Allows identifying JSON as if it was Python by adding some new builtins to the language
import builtins
builtins.true = True
builtins.false = False
builtins.null = None
'';
	};
}
