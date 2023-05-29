# vim: set ft=python:
from os import getcwd, uname
from pathlib import Path


#if  uname().sysname == 'Darwin' and ('__NIX_DARWIN_SET_ENVIRONMENT_DONE' not in ${...} or not $__NIX_DARWIN_SET_ENVIRONMENT_DONE):
#    source-bash /etc/bashrc

# set -e == $RAISE_SUBPROC_ERROR = True
# set -x == trace on; $XONSH_TRACE_SUBPROC = True
# $? == _.rtn

xontrib load direnv
xontrib load coreutils

# Insert to the front, because when we spawn xonsh in tmux we have raw python3
# paths added before these. That ends up screwing with finding the python3 version
# with all of our dependencies that we want
$PATH.insert(0, Path("~/.nix-profile/bin").expanduser())
$PATH.insert(0, Path("~/src/bin").expanduser())
$PATH.insert(0, Path("~/.local/bin").expanduser())
