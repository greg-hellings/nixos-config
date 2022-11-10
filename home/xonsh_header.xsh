# vim: set ft=python:
if  '__NIX_DARWIN_SET_ENVIRONMENT_DONE' not in ${...} or not $__NIX_DARWIN_SET_ENVIRONMENT_DONE:
    source-bash /etc/bashrc

# set -e == $RAISE_SUBPROC_ERROR = True
# set -x == trace on; $XONSH_TRACE_SUBPROC = True
# $? == _.rtn

import os

xontrib load direnv

# Insert to the front, because when we spawn xonsh in tmux we have raw python3
# paths added before these. That ends up screwing with finding the python3 version
# with all of our dependencies that we want
$PATH.insert(0, "${config.home.homeDirectory}/.nix-profile/bin")
$PATH.insert(0, "${config.home.homeDirectory}/src/bin")
