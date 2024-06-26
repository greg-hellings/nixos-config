# vim: set ft=python :

def bw_unlock():
    """Unlocks the BitWarden CLI and adds the resulting session code to the
    current environment variables. Also returns the code for them."""
    if "BW_SESSION" in ${...}:
        return $BW_SESSION
    result = $(bw unlock)
    while "BW_SESSION" not in result:
        result = $(bw unlock)
    lines = result.split("\n")
    l = [k for k in lines if 'BW_SESSION="' in k][0]
    left, right = l.split("=", 1)
    token = right[1:-1]
    $BW_SESSION = token
    return token

def _glrestart(args):
    sudo nixos-container run gitlab -- systemctl restart gitlab
    sudo nixos-container run gitlab -- systemctl restart nginx

def _cfetch(args):
    bw_unlock()
    $CIRCLECI_CLI_TOKEN=$(bw get password CircleCI) 
    compass workspace exec bazel run src/go/compass.com/tools/circleci_results_cache/fetch/cmd/fetch:fetch

def _rebuild(args):
    system = uname()
    if system.sysname == 'Darwin':
        darwin-rebuild --flake ~/.config/darwin switch
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
    if Path('/usr/bin/podman').exists():
        e = 'podman'
    else:
        e = 'docker'
    @(e) exec -ti @(args[0]) /bin/bash

def _pip_extras(args):
    import importlib_metadata
    print(importlib_metadata.metadata(args[0]).get_all('Provides-Extra'))

# Container stuff
def _newdock(args):
    if Path('/usr/bin/podman').exists():
        e = 'podman'
    else:
        e = 'docker'
    @(e) run -P --privileged=true -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v @(getcwd()):/dmnt -v /etc/pki:/etc/pki:ro -d --name @(args[1]) @(args[0]) /sbin/init
    rundock @(args[1])

def _unknown_host(args):
    sed -i -e @(args[0])d ~/.ssh/known_hosts

def _bake(args):
    from pathlib import Path
    templates = Path("~/.copier-templates/").expanduser()
    if not templates.exists():
        git clone src:greg/copier-templates.git ~/.copier-templates
    copier copy @(str(templates / args[0])) .

aliases['glrestart'] = _glrestart
aliases['cfetch'] = _cfetch
aliases['bake'] = _bake
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
