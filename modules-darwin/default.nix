{ ... }:

{
	system.stateVersion = 4;
	programs = {
		zsh.enable = true;
		bash.enable = true;
	};
	services.nix-daemon.enable = true;
	nix.gc.interval.Hour = 24;
}
