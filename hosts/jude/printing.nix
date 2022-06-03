{ pkgs, ... }:

{
	# ipp://printer.thehellings.lan:631/ - generic postscript printer
	services.printing = {
		enable = true;
		drivers = with pkgs; [
			gutenprint
			gutenprintBin
		];
	};
}
