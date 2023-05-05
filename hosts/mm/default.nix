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
			allowedTCPPorts = [ 53 ];
			allowedUDPPorts = [ 53 67 ];
		};
	};

	# Serves as the router, DHCP, and DNS for the site
	greg.router = {
		enable = true;
		wan = [ wanInterface "tailscale0" ];
		lan = [ lanInterface ];
	};
	greg.tailscale.enable = true;
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
				}];
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
