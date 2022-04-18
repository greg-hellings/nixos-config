{ ... }:

{
	programs.git = {
		enable = true;
		userName = "Greg Hellings";
		userEmail = "greg.hellings@gmail.com";
		aliases = {
			st = "status";
			ci = "commit";
			co = "checkout";
		};
		ignores = [
			".*.swp" ".*.swo" ".*.swn" # vim
			".idea" # IntelliJ
			".DS_Store" # Macs
			"Thumbs.db" # Windows
			".tox" # Tox temp directory
		];
		extraConfig = {
			push.default = "upstream";
			pull.rebase = "false";
		};
	};
}
