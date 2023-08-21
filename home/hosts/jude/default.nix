{ pkgs, ... }:

{
	home.packages = with pkgs; [
		gnucash
		ffmpeg
		handbrake
		libtheora
		makemkv
		synology-drive-client
	];
}
