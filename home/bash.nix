{ pkgs, ... }:

{
	programs.bash = {
		enable = true;
		shellAliases = {
			acp = "rsync --progress -ah";
			agbuild = "ansible-galaxy collection build";
			apub = "ansible-galaxy collection publish --api-key \${GALAXY_API_KEY}";
			calc = "bc";
			d = "deactivate";
			devroles = "cd ~/src/ansible_collections/devroles";
			gohome = "ssh greg@dns.greg-hellings.gmail.com.beta.tailscale.net -D localhost:10080";
			ll = "ls -l";
			molcol = "molecule -c ../../tests/molecule.yml";
			packaging = "cd ~/src/packaging";
			vdown = "vagrant destroy";
			vhalt = "vagrant halt";
			vos = "vagrant up --provision --provider openstack";
			vprov = "vagrant provision";
			vssh = "vagrant ssh";
			vup = "vagrant up --provision --provider libvirt";
			yaml2js = "python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)";
		};
		sessionVariables = {
			ANSIBLE_COLLECTIONS_PATH="\${HOME}/src/";
			CLICOLOR = "1";
			EDITOR = "${pkgs.vim}/bin/vim";
			GALAXY_API_KEY = "11498be21eb34b5776af72bcec59ddfdafcf27e5";
			GIT_SSL_NO_VERIFY = "True";
			LSCOLORS = "ExGxBxDxCxEgEdxbxgxcxd";
			MAVEN_OPTS = " -Dmaven.wagon.http.ssl.insecure=true ";
			OS_CLOUD = "default";
			SWORD_PATH = "\${HOME}/.sword";
			TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
			VAGRANT_CLOUD_TOKEN = "zCQN8OBMy6Kl2g.atlasv1.JHsu0HsHMDdqCWqyUjJuCKDH0DyDzOHhbDBCrphUyjOP8OoM9i39SYmtk3Q4DKxfZXE";
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
