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
			amend = "commit --amend";
		};
		ignores = [
			".*.swp" ".*.swo" ".*.swn" # vim
			".idea" # IntelliJ
			".DS_Store" # Macs
			"Thumbs.db" # Windows
			".tox" # Tox temp directory
			".eclipse"  # These next two are created by VSCodium plugins
			".bazelproject"
		];
		extraConfig = {
			init.defaultBranch = "main";
			push.default = "upstream";
			pull.rebase = "false";
			tag.sort = "version:refname";
		};
	};
}
