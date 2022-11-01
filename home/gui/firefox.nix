{ lib, pkgs, ... }:

let
	# For now, we ignore this and don't install it
	ffPkgs = if ( lib.hasSuffix "-darwin" pkgs.system )
		then pkgs.firefox-bin
		else pkgs.firefox-wayland.override { cfg.enableGnomeExtensions = true; };

	vars = {
		MOZ_ENABLE_WAYLAND = "1";
		XDG_CURRENT_DESKTOP = "sway";
	};
in with lib;
{
	programs.firefox = {
		enable = true;
		package = ffPkgs;
		extensions = with pkgs.nur.repos.rycee.firefox-addons; [
			bitwarden
			foxyproxy-standard
			multi-account-containers
			octotree
			refined-github
			tree-style-tab
			ublock-origin
		];
		profiles = {
			default.settings = {
				"app.update.auto" = false;
				"browser.ctrlTab.sortByRecentlyUsed" = true;
				"browser.startup.page" = 3;
				"browser.startup.homepage" = "https://thehellings.com";
				"doh-rollout.doorhanger-decision" = "UIDisabled";
				"doh-rollout.doneFirstRun" = true;
				"signon.rememberSignons" = false;
			};
		};
	};

	programs.bash.sessionVariables = vars;

	programs.xonsh.sessionVariables = vars;
}
