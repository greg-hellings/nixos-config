{ pkgs, ... }:

{
	imports = [
		./boot.nix
		./hardware-configuration.nix
		./podman.nix
		./printing.nix
		./virt.nix
	];
	programs.steam.enable = true;
	networking.hostName = "jude";
	networking.enableIPv6 = false;
	#systemd.oomd.enable = false;
	greg.tailscale.enable = true;
	greg.gnome.enable = true;
	greg.kde.enable = false;

	environment.systemPackages = with pkgs; [
		# Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
		gst_all_1.gstreamer
		# Common plugins like "filesrc" to combine within e.g. gst-launch
		gst_all_1.gst-plugins-base
		# Specialized plugins separated by quality
		gst_all_1.gst-plugins-good
		gst_all_1.gst-plugins-bad
		gst_all_1.gst-plugins-ugly
		# Plugins to reuse ffmpeg to play almost every video format
		gst_all_1.gst-libav
		# Support the Video Audio (Hardware) Acceleration API
		gst_all_1.gst-vaapi
		oathToolkit
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
