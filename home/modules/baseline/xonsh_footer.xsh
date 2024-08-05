# vim: set ft=python :

from tempfile import NamedTemporaryFile

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

def vpn(con, bwname):
    bw_unlock()
    base=$(bw get password @(bwname))
    secret=$(bw get totp @(bwname))
    #echo vpn.secrets.password:${base}$(oathtool -b -d "${digits}" -s "${period}" --totp "${secret}") > "${f}"

    with NamedTemporaryFile(delete_on_close=False) as fp:
        secret = f"vpn.secrets.password:{base}{secret}"
        fp.write(secret.encode("utf-8"))
        fp.close()
        nmcli c up @(con) passwd-file @(fp.name)

def _unlock(args):
    bw_unlock()
aliases['unlock'] = _unlock

def _ivr(args):
    vpn("350Main", "IVR Technology")
aliases['ivr'] = _ivr

def _glrestart(args):
    sudo nixos-container run gitlab -- systemctl restart gitlab
    sudo nixos-container run gitlab -- systemctl restart nginx
aliases['glrestart'] = _glrestart

def _cfetch(args):
    bw_unlock()
    $CIRCLECI_CLI_TOKEN=$(bw get password CircleCI) 
    compass workspace exec bazel run src/go/compass.com/tools/circleci_results_cache/fetch/cmd/fetch:fetch
aliases['cfetch'] = _cfetch

def _aws_creds(args):
    $AWS_ACCESS_KEY_ID=$(bw get username "AWS Access Key")
    $AWS_SECRET_ACCESS_KEY=$(bw get password "AWS Access Key")
aliases['aws_creds'] = _aws_creds

def _rebuild(args):
    system = uname()
    if system.sysname == 'Darwin':
        darwin-rebuild --flake ~/.config/darwin switch
    else:
        sudo nixos-rebuild switch
aliases['rebuild'] = _rebuild

def _yaml2json(args, stdin=None, stdout=None):
    import sys, yaml, json
    from yaml import CLoader
    json.dump(yaml.load(stdin, Loader=CLoader), stdout, indent=4)
aliases['yaml2json'] = _yaml2json

def _py2env(args):
    vox new @(args[0]) -p /usr/bin/python2
aliases['py2env'] = _py2env

def _py3env(args):
    vox new @(args[0])
aliases['py3env'] = _py3env

def _rundock(args):
    if Path('/usr/bin/podman').exists():
        e = 'podman'
    else:
        e = 'docker'
    @(e) exec -ti @(args[0]) /bin/bash
aliases['rundock'] = _rundock

def _pip_extras(args):
    import importlib_metadata
    print(importlib_metadata.metadata(args[0]).get_all('Provides-Extra'))
aliases['pip_extras'] = _pip_extras

# Container stuff
def _newdock(args):
    if Path('/usr/bin/podman').exists():
        e = 'podman'
    else:
        e = 'docker'
    @(e) run -P --privileged=true -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v @(getcwd()):/dmnt -v /etc/pki:/etc/pki:ro -d --name @(args[1]) @(args[0]) /sbin/init
    rundock @(args[1])
aliases['newdock'] = _newdock

def _unknown_host(args):
    sed -i -e @(args[0])d ~/.ssh/known_hosts
aliases['unknown_host'] = _unknown_host

def _bake(args):
    from pathlib import Path
    templates = Path("~/.copier-templates/").expanduser()
    if not templates.exists():
        git clone src:greg/copier-templates.git ~/.copier-templates
    copier copy @(str(templates / args[0])) .
aliases['bake'] = _bake

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
