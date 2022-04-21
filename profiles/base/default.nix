{ config, pkgs, agenix, ... }:

{
	imports = [
		./nix.nix
		./programs.nix
		./syncthing.nix
		./xonsh.nix
	];


	# I am a fan of network manager, myself
	networking.networkmanager.enable = true;

	# Enable the OpenSSH daemon for remote control
	services.openssh.enable = true;
	#services.openssh.permitRootLogin = "yes";

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.greg = {
		isNormalUser = true;
		createHome = true;
		extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
		shell = pkgs.xonsh;
		openssh.authorizedKeys.keys = [
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDLQRq55JKqLifX+31kEXyuoB8gfM+5thAlgR7XLPvvdu6g2a5cCWyozQ1I2oGbPRfJtzcJ5ifM7Ii2PuqAj3MdYFLHBEDOhIpBBWme9Ts2YB9HJ4NorBvB4zEfJd0Q7k2MmylyeBOwdwGz3bVqPRDcJbxWFMDHqr33FEs6SXdfyAQ5SvhWGARI84qz8zUUdOp6M4e3aIGO3cx1gA+YzYQ4FbUtL8+m1NFO8VoNFMZBMf5q0iF/SgEu5bmGWUCePia6DvfeBFQ2/y4Y7WmOj980WE+JmFTkIvmGruMYeGI8FuDQ2JIIIcehddy9bQbPF4VlGnTFsHqJYVRUUWc+vH1cPNMn01oB8s27ogf9e1lyhIN+cZOgp/jDt4eXcO4Wr04uwj7CI6m+d8iMQOa5Jv0hmNgqqiwOMVBlKeo0FCxlovzwvn/Lia9WZ74JqM6JwLCD8SZ0oFgiSIHOTHrQhr7iaCmj7X/0ey7VR8FnCrpeAJpG+ELTfWGshF1d9QR2zW7u4EsXTDLiuOmdJ+/KxwMvjMcWdlg2+Qch6SwulTQRxWaED2IWJo+YiAql8eaiVXu/eZJGLoiskGFZnONoLrzIT4pSjakPlrSpn/M/GkP1pDpaMkr24OhJsGpJNEU3F1ZcOMqy2iJzIxlPmU8Xg0I/OrnbJplpaXeRCqnmouJUJhWkaPzawaVyW7dtvprLWcpQtUgTRet18WLyOrLKlq1jwvNRMTPKUJ2IFJMpk2pNEP6bdiUxyMa4vrRIEU2p1zsYSUJpCRLtccZ/i/+yAqwnTA2L5TdAORi9nD2uCdM/Ljz52V3A14QapS6oqcoWx2soWKgnsbVXoG8DxmUTpll77Ze9t7Y5216SMInWuOu0vstP8ZcgFmWsiBgIYIuLA58abWHMxgD251phYidua6R3Gtkf8J/kYqTR1P6eJF1bt5efEg7FD2aL1QQZsYJo3CRNz7yVe1XqMdPbfe2mFXQVF9TDX5x6r9Ir3d0KiEmTlBdByz8nSyPJ8IQxC58NT4LNVQs3p2XH2Zcf6B4JOBSmV4NNBnLseFobsxniWjkWwZigED/D2iu3OXuuhmskCbw0hKy2rBcKffaSNMioVqYIiYNfKlMlSvAacQKqc/1HCpqgX8PwAcSgNSLy4K7/gIrTHmjY+g+CH7onzatWzkLo+0vsZRa/D/qwhhK2CU2FeU07mhnWxWuzqpJuqVaAwDTaEforK7nQUtAOFAZZP6qGhIoqsynYt4THb+QORb3QYfaP0PVgQwXfVU5Q8eUQFZ8A+siPtOASFjDumsIbseB5VzkF+UhvdseJwkX2+4pVFu8eHFDyvArYsHeGK6fBcQGJFQc2jSs6doIP9HD9IO2R ghelling@unknown38BAF87CD102"
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDv26EhyBZS9E5bcuZDHHkh/oeyINHXlsD3OEL1UjZekIsiHoMv2QHYq99cYO/CsTVGcZj4ZTOKxrQQ069Cm1II76nXJP9mb3+jip5QAE/zYSWfxi3SgQum95qmkQsx9mxeKFi4NfUU9qN9vpmJkn0hrvYWg8vU98bcYmkx4RtGW6EgZJed3347EtHshTqq3UfAbj3ErSQdCbEqgNOjokzGWmcx16HyyO5HoQj2FP7PGQmArzMz0V76BRsnpg97CoPKkoWoGk+P13BCWWXR9GCa2PbJ9uprzPa6Ib4+i9RJPdeSkUiLlFi6rBTHaZUT9WUIEaqNSq3bbu1bIqMXkifPeDw7m+TMfOBT8MUBciJaPlPTgXuz3T4kCHBI041hIt+/VqryGtxnT45IavyUaN3JWYntDbpG3eEW4N9IB2oGWuC/XuTJrsUaNpLPpApUKuozxhsFELBRepU+j+Wn4kgJJl8hy0n+WL63ZUee+/F23C7UNXoOc/wU3KbpxO6ipsTSkTzhZpQF2LOuA3JUs5t9ZaiCJ2P9r8axHiphCRcIYSbcCo3pZupf1eTDSXm+x9/UB2sfzErNEH4SdakoSdAi8jG8WhPVOs3BrIXjVBjvyBLeOH86EzBGR/Ba8X6MWoEW9Oau1C3P/z65VH8RHpvPvp6axlMynyVI1ygt5uheuQ== gregory.hellings@C02G48H8MD6R"
		];
	};

	i18n.defaultLocale = "en_US.UTF-8";

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	# The set of default values, which allow syou to keep system defaults set
	# to a predictable value as you upgrade the system
	system.stateVersion = "21.11";
}
