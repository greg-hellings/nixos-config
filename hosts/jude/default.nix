{ pkgs, ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
		./printing.nix
		./virt.nix
	];
	programs = {
		steam.enable = true;
		nix-ld.enable = true;
	};

	networking = {
		hostName = "jude";
		enableIPv6 = false;
		interfaces.enp12s0.useDHCP = true;
		firewall.enable = true;
	};
	greg = {
		tailscale.enable = true;
		gnome.enable = true;
		kde.enable = false;
	};

	environment.systemPackages = with pkgs; [
		bind  # For things like nslookup
		darktable
		gimp
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
		nix-du
		nix-tree
		oathToolkit
		synology-drive-client
		terraform
		vagrant
		ventoy

		# Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
		gst_all_1.gstreamer
		gst_all_1.gst-plugins-base
		gst_all_1.gst-plugins-good
		gst_all_1.gst-plugins-bad
		gst_all_1.gst-plugins-ugly
		gst_all_1.gst-libav
		gst_all_1.gst-vaapi
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
		xserver.videoDrivers = [ "nvidia" ];
	};
	hardware = {
		nvidia = {
			modesetting.enable = true;
			nvidiaSettings = true;
			open = true;
		};
		pulseaudio.enable = false;  # This conflicts with pipewire
		system76.enableAll = true;
	};
}
