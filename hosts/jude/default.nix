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

	networking.hostName = "jude";
	networking.enableIPv6 = false;
	#systemd.oomd.enable = false;
	greg.tailscale.enable = true;
	greg.gnome.enable = true;
	greg.kde.enable = false;

	environment.systemPackages = with pkgs; [
		busybox
		gimp
		gnucash
		flock
		ffmpeg
		handbrake
		libtheora
		makemkv
		oathToolkit
		synology-drive-client
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
			device = "/dev/nvme0n1p3";
			fsType = "ntfs-3g";
		};
	};
}
