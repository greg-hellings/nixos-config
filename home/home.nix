name: pkgs:

{
	imports = [
		./bash.nix
		./git.nix
		./vim.nix
		./ssh.nix
	];

	home.username = name;
	home.homeDirectory = if name == "root" then "/root" else "/home/${name}";
}
