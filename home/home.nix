name: { pkgs, lib, nixosConfig, ...}:

let
	guiImports = if nixosConfig.greg.gnome.enable then
		[ ./gui ] else [];

in {
	imports = [
		./modules
		./bash.nix
		./git.nix
		./ssh.nix
		./vim.nix
		./xonsh.nix
	] ++ guiImports;


	home.username = name;
	home.homeDirectory = if name == "root" then "/root" else "/home/${name}";
}
