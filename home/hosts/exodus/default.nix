{ pkgs, config, ... }:

{
	greg = {
		vscodium = true;
		development = true;
		gnome = true;
		gui = true;
	};
	home.packages = with pkgs; [
		cargo
		freeciv
		#freeciv_qt
	];
}
