{ lib, pkgs, ... }:

{
	programs.gnome-terminal = lib.mkIf ( pkgs.system != "x86_64-darwin") {
		enable = true;
		showMenubar = true;
		themeVariant = "dark";
		profile.default = {
			default = true;
			visibleName = "greg";
		};
	};
}
