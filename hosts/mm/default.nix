# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
	wanInterface = "enp2s0";
	lanInterface = "enp1s0";
	lanIpAddress = "10.177.1.1";
in

{
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
		];


	greg.home = false;

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.efi.efiSysMountPoint = "/boot/efi";

	users.users.gamemaster = {
		isNormalUser = true;
		createHome = true;
		shell = pkgs.bash;
		openssh.authorizedKeys.keys = [
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH960DgfJIyTKKke7mtQu73Byr8gp/BZSfkpAWAMDB8zBIgggJkbo6/C5jtCb9kXp3ULFi56bQYDHR7WOSTZ07G3nE5iKo++JXgOOGXAQKW4TQ4LP/Q7wJpDktBIlZwVdB46eQBMrML9YtV0l1q8R18y55su2ZB6VUEGUNiyDa4rM7iBNchizOgdYRbTeokvrYfxEZr18AjwNIerS6vRHTTzQsLZx64QxuTc7uM+aPOKAvzcD5mwqj+CzEzHQV7KhcbwN0mQS4QD0QBaIBLuB1ADmividLxOulj4zaVDF06JRIoT/o7l9Kz/CIohsDHMgDIG3upcFcCKLtuOLQd3wx3ZNC8uY+i5OskM8NOepq9St/c6aeMeLNyiUBvJNenbm5+nbqSXCHfOJW+SC4oaYOJZbV/pQgHotmjPQ0+oKCwMNoE0v4lRA0l3quySvIZAQxkLNPIo9bnk5oXnlAGzQaHcyojANnjDtbz19Fk4bRUKts6mL3CArUrHWEmftt1Ls= gamemaster@raspberrypi"
		];
	};

	networking = {
		hostName = "mm";
		domain = "mindmazeroom.lan";
		#nameservers = [ "127.0.0.53" ];
		interfaces = {
			"${wanInterface}".useDHCP = true;
			"${lanInterface}" = {
				useDHCP = false;
				ipv4.addresses = [{
					address = lanIpAddress;
					prefixLength = 24;
				}];
			};
		};
		firewall = {  # Might not strictly be necessary?
			allowedTCPPorts = [ 53 80 443 8123 ]; # 8091 8123
			allowedUDPPorts = [ 53 67 ];
		};
		extraHosts = (builtins.concatStringsSep "\n" [
			"${lanIpAddress} store.mindmazeroom.com"
		]);
	};

	# Serves as the router, DHCP, and DNS for the site
	greg = {
		router = {
			enable = true;
			wan = [ wanInterface "tailscale0" ];
			lan = [ lanInterface ];
		};
		tailscale.enable = true;
		proxies = {
			"mm.shire-zebra.ts.net".target = "http://127.0.0.1:8123";
			"store.mindmazeroom.com".target = "http://127.0.0.1:8123";
		};
	};
	services = {
		dnsmasq = {
			enable = true;
			settings = {
				domain = "mindmazeroom.lan";
				server = [
					"1.1.1.1"
					"100.100.100.100"
					"8.8.8.8"
				];
			};
		};
		create_ap = {
			enable = false;
			settings = {
				INTERNET_IFACE = "";
				WIFI_IFACE = "wlan0";
				SSID = "MM_Test";
				PASSPHRASE = "MindMaze2023";
			};
		};
		home-assistant = {
			enable = true;
			configDir = "/var/lib/hass";
			package = (pkgs.home-assistant.override {
				extraComponents = [
					"accuweather"
					"calendar"
					"cast"
					"lovelace"
				];
			}).overrideAttrs (oldAttrs: {
				doInstallCheck = false;
			});
			config = {
				logger.default = "info";
				default_config = {};
				esphome = {};  # Get these things loaded, even if not configured
				met = {};
				my = {};
				tts = [ { platform = "google_translate"; } ];
				http = {
					use_x_forwarded_for = true;
					trusted_proxies = [ "127.0.0.1" "::1" ];
					server_host = "127.0.0.1";
				};
				"automation manual" = [];
				"automation ui" = "!include automations.yaml";
				"script manual" = [];
				"script ui" = "!include scripts.yaml";
				"scene manual" = [];
				"scene ui" = "!include scenes.yaml";
			};
		};
		kea.dhcp4 = {
			enable = true;
			settings = {
				interfaces-config = {
					interfaces = [ lanInterface ];
				};
				lease-database = {
					name = "/var/lib/kea/dhcp4.leases";
					persist = true;
					type = "memfile";
				};
				renew-timer = 1000;
				rebind-timer = 2000;
				valid-lifetime = 4000;
				option-data = [{
					name = "domain-name-servers";
					data = "${lanIpAddress}";
				} {
					name = "routers";
					data = "10.177.1.1";
				}];
				subnet4 = [{
					subnet = "10.177.1.0/24";
					pools = [{
						pool = "10.177.1.10-10.177.1.250";
					}];
					reservations = [{
						hw-address = "9c:8e:cd:3f:3f:8c";
						hostname = "madscientist";
						ip-address = "10.177.1.249";
					} {
						hw-address = "9c:8e:cd:3f:40:a4";
						hostname = "saloon";
						ip-address = "10.177.1.248";
					} {
						hw-address = "9c:8e:cd:3f:40:d3";
						hostname = "jail";
						ip-address = "10.177.1.247";
					}];
				}];
			};
		};
		minidlna = {
			enable = true;
			openFirewall = true;
			settings = {
				inotify = "yes";
				media_dir = [
					"/mm-video"
				];
			};
		};
		# Configure keymap in X11
		xserver = {
			layout = "us";
			xkbVariant = "";
		};
	};

	# Set your time zone.
	time.timeZone = "America/Chicago";

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.greg = {
		isNormalUser = true;
		description = "Greg Hellings";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = with pkgs; [
		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
	];
	system.stateVersion = "22.05";
}
