{ config, pkgs, ... }:

let
	unstable = import <nixos-unstable> {};
	service_list = [ "podman-home-assistant.service" ];
in
{
	virtualisation.podman.enable = true;

	services.home-assistant = {
		enable = true;
		configDir = "/var/lib/hass";
		package = (pkgs.home-assistant.override {
			extraComponents = [
				"accuweather"
				"cast"
				"eufy"
				"lovelace"
				"tplink"
				"wiz"
				"zwave_js"
			];
		}).overrideAttrs (oldAttrs: {
			doInstallCheck = false;
		});

		config = {
			default_config = {};
			esphome = {};  # Get these things loaded, even if not configured
			met = {};
			tts = [ { platform = "google_translate"; } ];
			http = {
				use_x_forwarded_for = true;
				trusted_proxies = [ "127.0.0.1" "::1" ];
				server_host = "127.0.0.1";
			};
			"automation ui" = "!include automations.yaml";
			"script ui" = "!include scripts.yaml";
			"scene ui" = "!include scenes.yaml";
		};
	};

	# Although NixOS has a package for Home Assistant, it is not kept as up to date as the container and the upstream
	# is very vocal about only supporting their own container or the HAOS deployments. So we deploy the container here
	# and avoid any potential messes from that
	virtualisation.oci-containers = {
		backend = "podman";

		# I have ZWave devices. The easiest way to connect to them is the zwavejs2mqtt service running, so we spin up
		# its container and map the ZWave device into it
		containers.zwave = {
			image = "zwavejs/zwavejs2mqtt:latest";
			ports = [ "8091:8091" "3000:3000" ];
			volumes = [ "/var/lib/zwave:/usr/src/app/store" ];
			extraOptions = [
				"--device" "/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
			];
		};
	};

	# Both of the above container need storage for their configuration and devices, but it is not created correctly by
	# the container. So we add the creation of /var/lib/{zwave,hass} to the systemd Unit files
	systemd.services = {
		"podman-zwave".serviceConfig = {
			StateDirectory = "zwave";
			StateDirectoryMode = pkgs.lib.mkForce "0777";
		};
	};


	greg.proxies."smart.thehellings.lan".target = "http://127.0.0.1:8123";

	# Ensure that both ports are up and running. We keep 8123 directly open because we are on the LAN and sometimes want to connect
	# directly for troubleshooting Nginx configuration
	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 80 8123 ];
	};

	# No data is secure unless it is backed up! So we back up the data on this node to our NAS using Syncthing, from there we will
	# handle things like off site
	services.syncthing = {
		enable = true;
		folders = {
			"zwave-live" = {
				enable = true;
				path = "/var/lib/zwave";
				devices = [ "nas" ];
			};
		};
	};
}
