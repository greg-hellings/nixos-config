{ pkgs, ... }:

{
	programs.xonsh = {
		enable = true;
		config = ''
# set -e == $RAISE_SUBPROC_ERROR = True
# set -x == trace on; $XONSH_TRACE_SUBPROC = True
# $? == _.rtn

import os

$TIMEFORMAT = '%3Uu %3Ss %3lR %P%%'
$CLICOLOR = 1
$LSCOLORS = 'ExGxBxDxCxEgEdxbxgxcxd'
$EDITOR = '${pkgs.vim}/vim'
$PKG_CONFIG_PATH = '/usr/local/lib/pkgconfig'
# Tells vox where to find virtualenvs
$VIRTUALENV_HOME = $HOME + '/venv/'
$PROMPT = '{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {short_cwd}{branch_color}{curr_branch: {}}{RESET} {BOLD_BLUE}{prompt_end}{RESET} '


$SWORD_PATH = $HOME + '/.sword'
$OS_CLOUD = 'default'


$GOPATH = '~/.go'
$JAVA_HOME = '/etc/alternatives/java_sdk'
$MAVEN_OPTS = ' -Dmaven.wagon.http.ssl.insecure=true'


# Coloured man page support
# using 'less' env vars (format is '\E[<brightness>;<colour>m')
$LESS_TERMCAP_mb = "\033[01;31m"     # begin blinking
$LESS_TERMCAP_md = "\033[01;31m"     # begin bold
$LESS_TERMCAP_me = "\033[0m"         # end mode
$LESS_TERMCAP_so = "\033[01;44;36m"  # begin standout-mode (bottom of screen)
$LESS_TERMCAP_se = "\033[0m"         # end standout-mode
$LESS_TERMCAP_us = "\033[00;36m"     # begin underline
$LESS_TERMCAP_ue = "\033[0m"         # end underline


####################################
#
# Alias Time
#
####################################
aliases['ll'] = 'ls -l'

aliases['vup'] = 'vagrant up --provision --provider libvirt'
aliases['vos'] = 'vagrant up --provision --provider openstack'
aliases['vssh'] = 'vagrant ssh'
aliases['vhalt'] = 'vagrant halt'
aliases['vprov'] = 'vagrant provision'
aliases['vdown'] = 'vagrant destroy'

aliases['ac'] = 'vox activate'
aliases['d'] = 'vox deactivate'

aliases['devroles'] = 'cd ~/src/ansible_collections/devroles'
aliases['molcol'] = 'molecule -c ../../tests/molecule.yml'

aliases['packaging'] = 'cd ~/src/packaging'

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

# Open a new terminal tab (Gnome Terminal) in the same CWD
$PROMPT = '{vte_new_tab_cwd}' + $PROMPT
'';
	};
}
