{ pkgs, config, ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
		./virt.nix
	];
	programs = {
		steam.enable = true;
		nix-index = {
			enable = true;
			enableBashIntegration = false;
			enableFishIntegration = false;
			enableZshIntegration = false;
		};
		nix-ld.enable = false;
	};

	networking = {
		hostName = "jude";
		enableIPv6 = false;
		interfaces.enp12s0.useDHCP = true;
		firewall = {
			enable = false;
			allowedTCPPorts = [ 21000 ];
			allowedUDPPorts = [ 21000 21010 ];
		};
	};
	greg = {
		tailscale.enable = true;
		sway.enable = false;
		gnome.enable = true;
		kde.enable = false;
		print.enable = true;
	};

	boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

	environment.systemPackages = with pkgs; lib.mkMerge [
		[  # for Immersed
			cudatoolkit
			immersed-vr
			libva
		]
		[
			bind  # For things like nslookup
			create_ssl
			distrobox
			expect
			gimp
			go
			gparted
			gnucash
			graphviz
			flock
			ffmpeg
			handbrake
			imagemagick
			libtheora
			libxml2
			linode-cli
			makemkv
			oathToolkit
			usbutils
			vagrant
			ventoy
		]

		[
			# Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
			gst_all_1.gstreamer
			gst_all_1.gst-plugins-base
			gst_all_1.gst-plugins-good
			gst_all_1.gst-plugins-bad
			gst_all_1.gst-plugins-ugly
			gst_all_1.gst-libav
			gst_all_1.gst-vaapi
		]
	];
	fileSystems =  {
		"/boot" = {
			device = "/dev/nvme0n1p1";
			fsType = "auto";
		};
		"/windows" = {
			device = "/dev/nvme0n1p5";
			fsType = "ntfs-3g";
		};
		"/windows11" = {
			device = "/dev/nvme1n1p2";
			fsType = "ntfs-3g";
		};
	};

	# Let's do a sound thing
	services = {
		pipewire = {
			enable = true;
			alsa.enable = true;
			audio.enable = true;
			jack.enable = true;
			pulse.enable = true;
			wireplumber.enable = true;
		};
		locate.enable = true;
		xserver.videoDrivers = [ "nvidia" ];
	};
	hardware = {
		nvidia = {
			modesetting.enable = true;
			nvidiaSettings = true;
			#open = true;
		};
		pulseaudio.enable = false;  # This conflicts with pipewire
		system76.enableAll = true;
	};
}
