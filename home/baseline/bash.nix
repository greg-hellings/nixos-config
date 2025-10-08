{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      gh-personal = "$GH_CONFIG_DIR=\"${config.home.homeDirectory}/.config/gh/personal\" gh";
      ls = "ls --color";
      ll = "ls -l --color";

      calc = "bc";
      d = "deactivate";
    };
    sessionVariables = {
      ANSIBLE_COLLECTIONS_PATH = "\${HOME}/src/";
      CLICOLOR = "1";
      EDITOR = "${pkgs.vim}/bin/vim";
      GIT_SSL_NO_VERIFY = "True";
      LSCOLORS = "ExGxBxDxCxEgEdxbxgxcxd";
      MAVEN_OPTS = " -Dmaven.wagon.http.ssl.insecure=true ";
      OS_CLOUD = "default";
      SWORD_PATH = "\${HOME}/.sword";
      TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
    };
    profileExtra = ''
      if [ -e /etc/profile ]; then
      	. /etc/profile
      fi
    '';
    bashrcExtra = ''
      function swordtag {
      	if [ x"$1" == "x" ]; then
      		echo "Please provide tag version"
      		return
      	fi
      	svn cp http://crosswire.org/svn/sword/branches/sword-1-8-x/ http://crosswire.org/svn/sword/tags/sword-$1/
      }

      function newdock {
      	if [ x"$1" == "x" -o x"$2" == "x" ]; then
      		echo "expected arguments [name] [source]"
      		return
      	fi
      	podman run -P --privileged=true -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v "$(pwd):/dmnt" -t -i --name="$1" "$2" /bin/bash
      }

      function rundock {
      	podman start -a -i "$1"
      }

      function ac {
      	source ~/venv/''${1}/bin/activate
      }

      function py2env {
      	/usr/bin/virtualenv -p /usr/bin/python2 "''${HOME}/venv/''${1}"
      	"''${HOME}/venv/''${1}/bin/pip" install -U pip
      }

      function py3env {
      	VENV_NAME="''${1}"
      	#PYVERSION="$(python3 -c "import sys;print(sys.version[:sys.version.find('.',2)])")"
      	#SITE_PACKAGES_PATH="/usr/lib64/python''${PYVERSION}/site-packages/"
      	#VENV_SITE_PACKAGES="''${HOME}/venv/''${VENV_NAME}/lib64/python''${PYVERSION}/site-packages/"
      	# Create the virtualenv and update pip to latest
      	/usr/bin/python3 -m venv --clear "''${HOME}/venv/''${VENV_NAME}" --system-site-packages
      	"''${HOME}/venv/''${1}/bin/python3" -m pip install -U pip
      	# Link SELinux into the environment if necessary
      	#if [ -d "''${SITE_PACKAGES_PATH}" ]; then
      	#	ln -s "''${SITE_PACKAGES_PATH}/selinux" "''${VENV_SITE_PACKAGES}"
      	#	ln -s ''${SITE_PACKAGES_PATH}/_selinux*.so "''${VENV_SITE_PACKAGES}"
      	#else
      	#	echo "ERROR: LibSELinux not found for Python ''${PYVERSION}. Install system package to enable."
      	#fi
      }

      function unknown_host {
      	sed -i -e ''${1}d ~/.ssh/known_hosts
      }
    '';
  };
}
