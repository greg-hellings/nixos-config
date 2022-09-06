name: { pkgs, lib, gui, ...}:

let
	guiImports = if gui then
		[ ./gui ] else [];

in {
	imports = [
		./modules
		./ansible.nix
		./bash.nix
		./direnv.nix
		./git.nix
		./ssh.nix
		./vim.nix
		./xonsh.nix
	] ++ guiImports;


	home.stateVersion = "22.05";
	home.packages = with pkgs; [
		bitwarden-cli
		cdrtools
		diffutils
		ffmpeg
		findutils
		git
		gnupatch
		hms
		libtheora
		nano
		tmux
		transcrypt
		unzip
		wget
		x265
		yamllint
	];
}
