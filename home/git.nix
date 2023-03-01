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
			ups = "push -u origin HEAD";
		};
		ignores = [
			".*.swp" ".*.swo" ".*.swn" # vim
			".idea" # IntelliJ
			".DS_Store" # Macs
			"Thumbs.db" # Windows
			".tox" # Tox temp directory
		];
		extraConfig = {
			init.defaultBranch = "main";
			push.default = "upstream";
			pull.rebase = "false";
			tag.sort = "version:refname";
		};
	};
}
