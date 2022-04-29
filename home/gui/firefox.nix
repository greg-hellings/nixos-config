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
		enableGnomeExtensions = true;
		extensions = with pkgs.nur.repos.rycee.firefox-addons; [
			keepassxc-browser
			octotree
			refined-github
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
