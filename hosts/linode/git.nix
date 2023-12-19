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
