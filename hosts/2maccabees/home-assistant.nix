{ config, pkgs, ... }:

let
	#unstable-src = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
	#unstable = import unstable-src {};
	unstable = import <nixos-unstable> {};
in
{
	#services.home-assistant = {
	#	enable = true;
	#	applyDefaultConfig = true;
	#	configWritable = true;
	#	configDir = "/var/lib/hass";
	#	config = {
	#		default_config = {};
	#		met = {};
	#		frontend = {};
	#		http = {
	#			use_x_forwarded_for = true;
	#			trusted_proxies = [ "127.0.0.1" "::1" ];
	#		};
	#		"map" = {};
	#		cloud = {};
	#		mobile_app = {};
	#	};

	#	package = (unstable.home-assistant.override {
	#		extraComponents = [
	#			"accuweather"
	#			"cast"
	#			"cloud"
	#			"default_config"
	#			"esphome"
	#			"google"
	#			"google_assistant"
	#			"roomba"
	#			"synology_dsm"
	#			"tplink"
	#			"wiz"
	#			"zwave_js"
	#		];
	#		extraPackages = py: with unstable.python39Packages; [
	#			ifaddr
	#		];
	#	}).overrideAttrs (oldAttrs: {
	#		doInstallCheck = false;
	#	});
	#	openFirewall = true;
	#};

	virtualisation.podman.enable = true;

	virtualisation.oci-containers = {
		backend = "podman";
		containers."home-assistant" = {
			image = "ghcr.io/home-assistant/home-assistant:stable";
			ports = [ "127.0.0.1:8123:8123" ];
			volumes = [ "/var/lib/hass:/config" ];
			extraOptions = [
				"--network" "podman"
				"--network" "podman66:ip=192.168.66.193"
			];
		};
	};

	#systemd.services.podman66 = {
		#wantedBy = [ "podman-home-assistant.service" ];
		#serviceConfig = {
			#Type = "oneshot";
			#ExecStart = ''
				#${pkgs.podman}/bin/podman network create -d macvlan -o parent=vlan66 --subnet 192.168.66.0/24 --ip-range 192.168.66.192/26 --gateway 192.168.66.1 podman66 || true
			#'';
		#};
	#};

	services.nginx = {
		enable= true;
		virtualHosts."smart.thehellings.lan".locations."/" = {
			proxyPass = "http://127.0.0.1:8123";
			extraConfig = ''
				proxy_set_header Host $host;
				proxy_http_version 1.1;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_set_header Upgrade $http_upgrade;
				proxy_set_header Connection $connection_upgrade;
			'';
		};
	};

	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 80 8123 ];
	};
}
