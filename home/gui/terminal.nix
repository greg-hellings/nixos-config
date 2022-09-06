{ ... }:

{
	programs.gnome-terminal = {
		enable = true;
		showMenubar = true;
		themeVariant = "dark";
		profile.default = {
			default = true;
			visibleName = "greg";
		};
	};
}
