{ pkgs, ... }:

{
	imports = [
		../../vscodium.nix
	];

	home.packages = with pkgs; [
		gimp
		gnucash
		ffmpeg
		handbrake
		libtheora
		makemkv
		synology-drive-client
		vagrant
	];
}
