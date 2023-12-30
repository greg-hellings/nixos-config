{ config, pkgs, ... }:

let
	srcDomain = "src.thehellings.com";
in {
	greg.proxies."${srcDomain}" = {
		target = "http://git.thehellings.lan";
		ssl = true;
		genAliases = false;
		extraConfig = ''
		proxy_set_header X-Forwarded-Proto https;
		proxy_set_header X-Forwarded-Ssl on;
		'';
	};

	services.haproxy = {
		enable = true;
		config = builtins.concatStringsSep "\n" [
			"global"
			"	daemon"
			"	maxconn 20"
			
			"defaults"
			"	timeout connect 500s"
			"	timeout client 500s"
			"	timeout server 1h"

			"frontend gitsshd"
			"	bind *:2222"
			"	default_backend gitssh"
			"	timeout client 1h"

			"backend gitssh"
			"	mode tcp"
			"	server git-thehellings-lan git.thehellings.lan:2222"
		];
	};

	##########################################################################################
	###########
	#                       CI SERVICES
	##########
	##########################################################################################
	virtualisation.oci-containers = {
		backend = "podman";
	};

	virtualisation.podman = {
		enable = true;
		dockerCompat = true;
	};
}
