{ lib, pkgs, ... }:

let
	ffPkgs = wayland: if wayland
		then [ pkgs.firefox-wayland ]
		else [ pkgs.firefox ];

	vars = {
		MOZ_ENABLE_WAYLAND = "1";
		XDG_CURRENT_DESKTOP = "sway";
	};
in with lib;
{
	programs.firefox = {
		enable = true;
		package = pkgs.firefox-wayland.override {
			cfg = {
				enableGnomeExtensions = true;
			};
		};
		extensions = with pkgs.nur.repos.rycee.firefox-addons; [
			bitwarden
			octotree
			refined-github
			tree-style-tab
			ublock-origin
		];
		profiles = {
			default.settings = {
				"browser.startup.page" = 3;
				"browser.startup.homepage" = "https://thehellings.com";
				"doh-rollout.doorhanger-decision" = "UIDisabled";
				"doh-rollout.doneFirstRun" = true;
			};
		};
	};

	programs.bash.sessionVariables = vars;

	programs.xonsh.sessionVariables = vars;
}
