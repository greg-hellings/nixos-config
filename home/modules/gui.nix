{ config, pkgs, lib, ... }:

let
	cfg = config.greg.gui;

	excludes = systems: opts: (
		if ( builtins.all (x: pkgs.system != x) systems ) then opts else []
	);

	# For now, we ignore this and don't install it
	ffPkgs = pkgs.firefox.override { cfg.enableGnomeExtensions = true; };

	vars = {
		XDG_CURRENT_DESKTOP = "GNOME";
	};
in {
	options.greg.gui = lib.mkEnableOption "Enable GUI programs";

	config = (lib.mkIf cfg {
		# These packages are Linux only
		home.packages = with pkgs; ( excludes ["x86_64-darwin" "aarch64-darwin"]
		[
			cdrtools
			element-desktop
			freetube
			qpwgraph
			vlc
			x265
		]) ++

		# x86_64-linux only
		( excludes ["x86_64-darwin" "aarch64-darwin" "aarch64-linux"]
		[
			bitwarden
			discord
			endeavour
			gnucash
			jellyfin-media-player
			libreoffice
			#logseq
			nextcloud-client
			slack
		]) ++

		# Items that are not supported on ARM/Linux
		( excludes ["aarch64-linux"]
		[
			onlyoffice-bin
			synology-drive-client
			zoom-us
		]);

		programs.firefox = {
			enable = (! pkgs.stdenv.hostPlatform.isDarwin);
			package = ffPkgs;
			profiles = {
				default = {
					isDefault = true;
					id = 0;
					search.default = "DuckDuckGo";
					settings = {
						"app.update.auto" = false;
						"browser.ctrlTab.sortByRecentlyUsed" = true;
						"browser.startup.page" = 3;
						"browser.startup.homepage" = "https://thehellings.com";
						"doh-rollout.doorhanger-decision" = "UIDisabled";
						"doh-rollout.doneFirstRun" = true;
						"signon.rememberSignons" = false;
					};
					extensions = with pkgs.nur.repos.rycee.firefox-addons; [
						bitwarden
						gsconnect
						foxyproxy-standard
						multi-account-containers
						octotree
						refined-github
						tree-style-tab
						ublock-origin
					];
				};
			};
		};

		# This is supposed to be in support of Firefox, but I dunno...
		programs.bash.sessionVariables = vars;
		programs.xonsh.sessionVariables = vars;
	});
}
