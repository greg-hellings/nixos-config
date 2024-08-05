{ pkgs, config, ... }:

{
	greg = {
		development = true;
		gnome = true;
		gui = true;
	};
	home.packages = with pkgs; [
		cargo
	];
}
