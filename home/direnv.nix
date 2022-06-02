{ pkgs, ... }:

{
	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
	};

	home.packages = [
		pkgs.xonsh-direnv
	];
}
