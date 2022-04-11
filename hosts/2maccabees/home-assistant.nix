{ config, pkgs, ... }:

let
	unstable = import <nixos-unstable> {};
	service_list = [ "podman-home-assistant.service" ];
in
{
	virtualisation.podman.enable = true;

	# Although NixOS has a package for Home Assistant, it is not kept as up to date as the container and the upstream
	# is very vocal about only supporting their own container or the HAOS deployments. So we deploy the container here
	# and avoid any potential messes from that
	virtualisation.oci-containers = {
		backend = "podman";
		containers."home-assistant" = {
			image = "ghcr.io/home-assistant/home-assistant:stable";
			ports = [ "127.0.0.1:8123:8123" ];
			volumes = [ "/var/lib/hass:/config" ];
			extraOptions = [
				"--device" "/dev/ttyAMA0"
			];
		};

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
		"podman-home-assistant" = {
			serviceConfig = {
				StateDirectory = "hass";
				StateDirectoryMode = pkgs.lib.mkForce "0755";
			};
		};

		"podman-zwave".serviceConfig.StateDirectory = "zwave";
	};


	# Podman 3.4, which is in NixOS 21.11 does not support creating multiple network interfaces during launch. Starting in Podman
	# 4.0 (NixOS 22.05) that will be possible. For now, adding this sidecar service that executes after every time the Home Assistant
	# container is started will do the necessary Podman commands to attach the container to the interface for VLAN 66. Once we
	# upgrade to NixOS 22.05 this service can go away and we can explicitly add two "--network" options to the Home Assistant container
	systemd.services."home-assistant-network-attach" = {
		requires = service_list;
		path = [ pkgs.podman pkgs.coreutils ];
		script = "sleep 10 && podman network connect podman66 home-assistant";
		wantedBy = service_list;
		serviceConfig = {
			Type = "oneshot";
		};
	};

	# This ensures that Podman has a separate network configured to attach to my IOT VLAN so that Home Assistant is able to communicate
	# with my devices as well as with the rest of the LAN.
	systemd.services.podman66 = {
		wantedBy = service_list;
		before = service_list;
		path = [ pkgs.podman ];
		script = "podman network create -d macvlan -o parent=vlan66 --subnet 192.168.66.0/24 --ip-range 192.168.66.192/26 --gateway 192.168.66.1 podman66 || true";
		serviceConfig = {
			Type = "oneshot";
		};
	};

	# I do not want to have to remember the port number for Home Assistant's UI, so we use Nginx to proxy communication from
	# smart.thehellings.lan to the Home Assistant UI
	# After the first activation of this container, before you can access the Home Assistant UI, you need to ensure that the
	# Home Assistant's configuration at /var/lib/hass/configuration.yaml includes the following option. Update the IP address
	# if you have changed the value of your default podman network.
	# ```yaml
	# http:
	#   use_x_forwarded_for: true
	#   trusted_proxies:
	#     - "10.88.0.1"
	# ```
	# Home assistant will not accept connections from the proxy if these values are not set. If you are adding those values
	# manually after initial creation of the containers, then you will need to issue `systemctl restart podman-home-assistant.service`
	# for Home Assistant to pick up the new values. After that, proxy connections should work well. If you are sitting behind
	# multiple layers of proxies, then add more of them in the list. The list also accepts subnet notation in case you have
	# multiple potentially incoming connections. So you could do "10.88.0.1/24", according to the docs. However, that has not
	# worked in my testing, as Home Assistant throws an error on start up saying that value is invalid
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
			"asdf-fdsa" = {
				enable = true;
				path = "/var/lib/hass";
				devices = [ "nas" ];
			};

			"zwave-live" = {
				enable = true;
				path = "/var/lib/zwave";
				devices = [ "nas" ];
			};
		};
	};
}
